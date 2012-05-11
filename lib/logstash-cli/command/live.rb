#!/usr/bin/env ruby
# vim:filetype=ruby
require 'rubygems'
require 'bundler/setup'
begin
  require 'tire'
  require 'slop'
  require 'time'
rescue LoadError
  puts "You seem to be missing some key libraries"
  puts "please run `gem install bundler --no-ri --no-rdoc; bundle install`"
end

begin
  require 'yajl/json_gem'
rescue LoadError
  puts "`gem install yajl-ruby for better performance"
end

opts = Slop.parse do
  banner "Usage: search.rb -i <index> -f <facility>"
  on :i, :index=, "index to search (default: logstash-#{Time.now.strftime('%Y.%m.%d')})", :default => "logstash-#{Time.now.strftime('%Y.%m.%d')}"
  on :f, :facility=, "REQUIRED: Facility(application name) to use", nil
  on :s, :size=, "number of results to return (default: 500)", true, :default => 500
  on :c, :class_name=, "optional class name to narrow results by", nil
  on :g, :grep=, "optional search on message content. Warning!!! This is slow", true
  on :exceptions, "toggle exception search. Warning!!! This is slow", :default => false
  on :live, "runs in live logging mode. This is A LOT of output. Please use non-wildcard facilities", :default => false
  on :fields=, Array, "optional comma-separated list of fields to display (tstamp, msg, file, class_name, service) in order (default: tstamp,service,msg)"
  on :h, :help, 'Print this help message', :tail => true do
    #puts help
    puts <<-EOF

--------
Examples
--------
- last 10 results log entries from curation including timestamp, classname and message:

search.rb -f curation* -s 10 --fields tstamp,class_name,msg

- last 5 entries for class name com.va (note the quote around * in the -f option):

search.rb -f "*" -s 5 -c com.va.*

- last 20 entries everywhere with timestamp, service name and message

search.rb -f "*" -s 20 --fields tstamp,service,msg

- last 5 exceptions everywhere

search.rb -f "*" -s 5 --exceptions

- live tail tracker_web

search.rb -f tracker_web --live

- live tail foo with custom display

search.rb -f foo --live --fields tstamp,service,class_name,msg

    EOF
    exit
  end
end

if opts[:live]
  require 'amqp'
  require 'yajl/json_gem'
  #https://github.com/ruby-amqp/amqp/pull/74
  #URL naming scheme
  AMQP.start("amqp://logstash:bar@localhost:7777") do |connection, open_ok|
    channel = AMQP::Channel.new(connection, :auto_recovery => true)
    exchange_name = "rawlogs"

    channel.queue("", :auto_delete => true, :durable => false) do |queue, declare_ok|
      queue.bind(exchange_name, :routing_key => opts[:facility])
      queue.subscribe do |payload|
        parsed_message = JSON.parse(payload)
        require 'pp'
        pp parsed_message
        service = parsed_message["@fields"]["facility"]
        class_name = parsed_message["@fields"]["_logger"]
        file = parsed_message["@fields"]["file"]
        msg = parsed_message["@message"]
        #msg = parsed_message["@fields"]["full_message"]
        tstamp = Time.iso8601(parsed_message["@timestamp"]).localtime.iso8601
        fields = opts[:fields] || ["tstamp", "service", "msg"]
        vals = fields.map {|x| x == fields[0] ? "\e[1m[#{eval(x)}]\e[0m" : eval(x)}
        display = vals.join(" - ")
        puts display
      end
    end

    trap("INT") { puts "Shutting down..."; connection.close { EM.stop };exit }
  end
end

if opts[:facility].nil?
  puts "Facility (matches name of service) CANNOT be empty!"
  require 'pp'
  pp opts
  exit
end

begin
  Tire.configure {url "http://localhost:9200"}
  puts opts[:index]
  search = Tire.search(opts[:index]) do
    query do
      boolean do
        must { string 'HOSTNAME:shipper'}
        #must { string "facility:#{opts[:facility]}" } unless opts[:facility].nil?
        #must { string "_logger:#{opts[:class_name]}" } unless opts[:class_name].nil?
        #must { string "full_message:Exception*" } if opts[:exceptions]
        must { string "message:#{opts[:grep]}*" } if opts[:grep]
      end
    end
    sort do
      by :@timestamp, 'desc'
    end
    size opts[:size]
  end
rescue Exception => e
  puts "\nSomething went wrong with the search. This is usually do to lucene query parsing of the 'grep' option"
  exit
end

search.results.sort {|a,b| a[:@timestamp] <=> b[:@timestamp] }.each do |res|
  service = res[:@fields][:facility]
  class_name = res[:@fields][:_logger]
  file = res[:@fields][:file]
  #msg = res[:@fields][:full_message]
  msg = res[:@fields][:message]
  tstamp = Time.iso8601(res[:@timestamp]).localtime.iso8601
  fields = opts[:fields] || ["tstamp", "service", "msg"]
  vals = fields.map {|x| x == fields[0] ? "\e[1m[#{eval(x)}]\e[0m" : eval(x)}
  display = vals.join(" - ")
  puts display
end
