require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'amqp'
require 'tire'
require 'time'
if RUBY_VERSION > '1.9'
  require 'csv'
else
  require 'fastercsv'
end
require 'logstash-cli/command'

module LogstashCli
  class CLI < Thor

    include LogstashCli::Command

    desc "grep PATTERN", "Search logstash for a pattern"
    method_option :esurl , :default => 'http://localhost:9200', :desc => "URL to connect to elasticsearch"
    method_option :index_prefix , :default => "logstash-", :desc => "Logstash index prefix"
    method_option :from , :default => "#{Time.now.strftime('%Y-%m-%d')}", :desc => "Begin date"
    method_option :to, :default => "#{Time.now.strftime('%Y-%m-%d')}", :desc => "End date"
    method_option :format , :default => 'plain', :desc => "Format to use for exporting (plain,csv,json)"
    method_option :size , :default => 500, :desc => "Number of results to return"
    method_option :last , :default => nil, :desc => "Specify period since now f.i. 1d"
    method_option :meta , :default => "type,message", :desc => "Meta Logstash fields to show"
    method_option :fields , :default => "", :desc => "Logstash Fields to show"
    method_option :delim , :default => "|", :desc => "plain or csv delimiter"

    def grep(pattern)
      _grep(pattern,options)
    end

    desc "tail", "Stream a live feed via AMQP"
    method_option :url,  :desc => "Alternate way to specify settings via an AMQP Url f.i. amqp://logstash:foopass@localhost:5672. \n This takes precendence over other settings. Note that username and password need to be percentage encoded(URL encoded) in case of special characters",:aliases => "\--amqpurl"
    method_option :user, :default => 'logstash', :desc => "User to connect to AMQP"
    method_option :password, :default => 'foo', :desc => "Password to connect to AMQP"
    method_option :vhost, :default => '/', :desc => "VHost to connect to AMQP"
    method_option :port, :default => 5672, :desc => "Port to connect to AMQP"
    method_option :host, :default => 'localhost' , :desc => "Host to connect to AMQP"
    method_option :ssl, :default => false , :desc => "Enable SSL to connect to AMQP", :type => :boolean

    method_option :exchange, :default => 'rawlogs', :desc => "Exchange name"
    method_option :exchange_type, :default => 'direct', :desc => "Exchange Type"
    method_option :durable, :default => false, :desc => "Durable Exchange or not", :type => :boolean
    method_option :auto_delete, :default => false, :desc => "Autodelete Exchange or not" , :type => :boolean
    method_option :persistent, :default => false, :desc => "Persistent Exchange or not", :type => :boolean
    method_option :key, :default => '#', :desc => "Routing key"
    method_option :format , :default => 'plain', :desc => "Format to use for exporting (plain,csv,json)"
    method_option :meta, :default => "timestamp,type,message", :desc => "Meta Logstash fields to show"
    method_option :delim, :default => "|", :desc => "plain or csv delimiter"

    def tail()
      _tail(options)
    end

    desc "count PATTERN", "Return most frequent values of a field within a pattern and optionally show associated fields"
    method_option :esurl , :default => 'http://localhost:9200', :desc => "URL to connect to elasticsearch"
    method_option :index_prefix , :default => "logstash-", :desc => "Logstash index prefix"
    method_option :from , :default => "#{Time.now.strftime('%Y-%m-%d')}", :desc => "Begin date"
    method_option :to, :default => "#{Time.now.strftime('%Y-%m-%d')}", :desc => "End date"
    method_option :format , :default => 'csv', :desc => "Format to use for exporting (plain,csv,json)"
    method_option :size , :default => 10, :desc => "Number of results per index to show"
    method_option :last , :default => nil, :desc => "Specify period since now f.i. 1d"
    method_option :meta , :default => "", :desc => "Meta Logstash fields to show"
    method_option :fields , :default => "", :desc => "Logstash fields to show"
    method_option :countfield , :required => true, :desc => "Logstash field to count"
    method_option :countsize , :default => 50, :desc => "Number of most frequent values to return"
    method_option :delim , :default => "|", :desc => "plain or csv delimiter"

    def count(pattern)
      _count(pattern,options)
    end

  end
end
