require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'tire'
require 'time'
require 'fastercsv'
require 'logstash-cli/command/grep'

module LogstashCli
  class CLI < Thor

    include LogstashCli::Command

    desc "grep PATTERN", "Search logstash for a pattern"
    method_option :esurl , :default => 'http://localhost:9200', :desc => "URL to connect to elasticsearch"
    method_option :index_prefix , :default => "logstash-", :desc => "Logstash index prefix"
    method_option :from , :default => "#{Time.now.strftime('%Y-%m-%d')}", :desc => "Begin date"
    method_option :to, :default => "#{Time.now.strftime('%Y-%m-%d')}", :desc => "End date"
    method_option :format , :default => 'csv', :desc => "Format to use for exporting"
    method_option :size , :default => 500, :desc => "Number of results to return"
    method_option :last , :default => nil, :desc => "Specify period since now f.i. 1d"
    method_option :meta , :default => "type,message", :desc => "Meta Logstash fields to show"
    method_option :fields , :default => "message,program", :desc => "Logstash Fields to show"
    method_option :delim , :default => "|", :desc => "csv delimiter"
    def grep(pattern)
      _grep(pattern,options)
    end

  end
end
