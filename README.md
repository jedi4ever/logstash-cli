** Work in progress **

## Description

A cli tool to query an elasticsearch host for logstash information.
Because let's face it, we're CLI junkies :)

Mucho inspired by a gist of the eminent @lusis - <https://gist.github.com/1388077>

## Installation
Installation using the usual steps

Install rvm , (no gem yet)

    $ git clone thisrepo
    $ cd thisrepo
    $ gem install bundler
    $ bundle install

## Usage

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

## Examples

    $ logstash-cli grep --esurl="http://logger-1.jedi.be:9200" '@message:jedi4ever AND program:sshd' --last 5d --format csv --delim ':'
## TODO

- find a way to query existing instances
- specify last 15m 
- find a way to get the results by streaming instead of loading all in memory (maybe pagination will help here)
