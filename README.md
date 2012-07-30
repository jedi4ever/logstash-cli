** Work in progress **

## Description

A cli tool to query an elasticsearch host for logstash information.
Because let's face it, we're CLI junkies :)

Mucho inspired by a gist of the eminent @lusis - <https://gist.github.com/1388077>

## Installation
### As a gem

    $ gem install logstash-cli

### From github

    Tested with rvm and ruby-1.8.7

    $ git clone git://github.com/jedi4ever/logstash-cli.git
    $ cd logstash-cli
    $ gem install bundler
    $ bundle install

## Usage

### Using the Gem

    $ logstash-cli

### Using the Github version - through bundler

    $ bundle exec bin/logstash-cli 

## Commandline Options

### Grep

    Usage:
      logstash-cli grep PATTERN

    Options:
      [--index-prefix=INDEX_PREFIX]  # Logstash index prefix
                                     # Default: logstash-
      [--fields=FIELDS]              # Logstash Fields to show
                                     # Default: message,program
      [--meta=META]                  # Meta Logstash fields to show
                                     # Default: type,message
      [--to=TO]                      # End date
                                     # Default: Today in YYYY-MM-DD form
      [--delim=DELIM]                # plain or csv delimiter
                                     # Default: |
      [--format=FORMAT]              # Format to use for exporting
                                     # Default: csv
      [--from=FROM]                  # Begin date
                                     # Default: Today in YYYY-MM-DD form
      [--size=SIZE]                  # Number of results to return
                                     # Default: 500
      [--esurl=ESURL]                # URL to connect to elasticsearch
                                     # Default: http://localhost:9200
      [--last=LAST]                  # Specify period since now f.i. 1d

    Search logstash for a pattern

### Tail

    Usage:
      logstash-cli tail

    Options:
          [--host=HOST]                    # Host to connect to AMQP
                                           # Default: localhost
      --amqpurl, [--url=URL]               # Alternate way to specify settings via an AMQP Url f.i. amqp://logstash:foopass@localhost:5672. 
     This takes precendence over other settings. Note that username and password need to be percentage encoded(URL encoded) in case of special characters
          [--auto-delete]                  # Autodelete Exchange or not
          [--vhost=VHOST]                  # VHost to connect to AMQP
                                           # Default: /
          [--persistent]                   # Persistent Exchange or not
          [--ssl]                          # Enable SSL to connect to AMQP
          [--user=USER]                    # User to connect to AMQP
                                           # Default: logstash
          [--meta=META]                    # Meta Logstash fields to show
                                           # Default: timestamp,type,message
          [--format=FORMAT]                # Format to use for exporting (plain,csv,json)
                                           # Default: csv
          [--key=KEY]                      # Routing key
                                           # Default: #
          [--port=PORT]                    # Port to connect to AMQP
                                           # Default: 5672
          [--exchange=EXCHANGE]            # Exchange name
                                           # Default: rawlogs
          [--password=PASSWORD]            # Password to connect to AMQP
                                           # Default: foo
          [--delim=DELIM]                  # plain or csv delimiter
                                           # Default: |
          [--exchange-type=EXCHANGE_TYPE]  # Exchange Type
                                           # Default: direct
          [--durable]                      # Durable Exchange or not

    Stream a live feed via AMQP

### Count

Usage:
  logstash-cli count PATTERN --countfield=COUNTFIELD

Options:
  [--meta=META]                  # Meta Logstash fields to show
  [--last=LAST]                  # Specify period since now f.i. 1d
  [--from=FROM]                  # Begin date
                                 # Default: Today in YYYY-MM-DD form
  [--delim=DELIM]                # plain or csv delimiter
                                 # Default: |
  --countfield=COUNTFIELD        # Logstash field to count
  [--countsize=COUNTSIZE]        # Number of most frequent values to return
                                 # Default: 50
  [--format=FORMAT]              # Format to use for exporting (plain,csv,json)
                                 # Default: csv
  [--to=TO]                      # End date
                                 # Default: Today in YYYY-MM-DD form
  [--fields=FIELDS]              # Logstash fields to show
  [--size=SIZE]                  # Number of results per index to show
                                 # Default: 10
  [--esurl=ESURL]                # URL to connect to elasticsearch
                                 # Default: http://localhost:9200
  [--index-prefix=INDEX_PREFIX]  # Logstash index prefix
                                 # Default: logstash-

Return most frequent values of a field within a pattern and optionally show associated fields

## Examples

    $ logstash-cli grep --esurl="http://logger-1.jedi.be:9200" '@message:jedi4ever AND program:sshd' --last 5d --format csv --delim ':'

    $ logstash-cli tail --amqpurl="amqp://logger-1.jedi.be:5672" --key="program.sshd"

    $ logstash-cli count --esurl="http://logger-1.jedi.be:9200" '@message:jedi4ever' --countfield=program

## TODO

- find a way to query existing instances
- specify last 15m 
- find a way to get the results by streaming instead of loading all in memory (maybe pagination will help here)
- produce ascii histograms
- or sparklines
