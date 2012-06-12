require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'amqp'
require 'tire'
require 'time'
require 'fastercsv'
require 'logstash-cli/command'

module LogstashCli
  class CLI < Thor

    include LogstashCli::Command

    desc "grep PATTERN", "Search logstash for a pattern"
    method_option :esurl , :default => 'http://localhost:9200', :desc => "URL to connect to elasticsearch"
    method_option :index_prefix , :default => "logstash-", :desc => "Logstash index prefix"
    method_option :from , :default => "#{Time.now.strftime('%Y-%m-%d')}", :desc => "Begin date"
    method_option :to, :default => "#{Time.now.strftime('%Y-%m-%d')}", :desc => "End date"
    method_option :format , :default => 'csv', :desc => "Format to use for exporting (plain,csv,json)"
    method_option :size , :default => 500, :desc => "Number of results to return"
    method_option :last , :default => nil, :desc => "Specify period since now f.i. 1d"
    method_option :meta , :default => "type,message", :desc => "Meta Logstash fields to show"
    method_option :fields , :default => "", :desc => "Logstash Fields to show"
    method_option :delim , :default => "|", :desc => "plain or csv delimiter"

    def grep(pattern)
      _grep(pattern,options)
    end

    desc "tail", "Stream a live feed via AMQP"
    method_option :amqpurl, :default => 'amqp://logstash:foopass@localhost:5672', :desc => "URL to connect to AMQP"
    method_option :exchange, :default => 'rawlogs', :desc => "Exchange name"
    method_option :key, :default => '#', :desc => "Routing key"
    method_option :format , :default => 'csv', :desc => "Format to use for exporting (plain,csv,json)"
    method_option :meta, :default => "timestamp,type,message", :desc => "Meta Logstash fields to show"
    method_option :delim, :default => "|", :desc => "csv delimiter"

    def tail()
      _tail(options)
    end

  end
end
