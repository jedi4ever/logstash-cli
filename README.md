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
                                     # Default: 2012-05-11
      [--delim=DELIM]                # csv delimiter
                                     # Default: |
      [--format=FORMAT]              # Format to use for exporting
                                     # Default: csv
      [--from=FROM]                  # Begin date
                                     # Default: 2012-05-11
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
      [--meta=META]          # Meta Logstash fields to show
                             # Default: timestamp,type,message
      [--delim=DELIM]        # csv delimiter
                             # Default: |
      [--key=KEY]            # Routing key
                             # Default: #
      [--format=FORMAT]      # Format to use for exporting
                             # Default: csv
      [--amqpurl=AMQPURL]    # URL to connect to AMQP
                             # Default: amqp://localhost:5672
      [--exchange=EXCHANGE]  # Exchange name
                             # Default: rawlogs

    Stream a live feed via AMQP

## Examples

    $ logstash-cli grep --esurl="http://logger-1.jedi.be:9200" '@message:jedi4ever AND program:sshd' --last 5d --format csv --delim ':'

    $ logstash-cli tail --amqpurl="amqp://logger-1.jedi.be:5672" --key="program.sshd"

## TODO

- find a way to query existing instances
- specify last 15m 
- find a way to get the results by streaming instead of loading all in memory (maybe pagination will help here)
- produce ascii histograms
- or sparklines
