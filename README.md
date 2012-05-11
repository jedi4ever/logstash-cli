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

    bundle exec bin/logstash-cli
    Usage:
      logstash-cli grep PATTERN

    Options:
      [--index-prefix=INDEX_PREFIX]  # Logstash index prefix
                                     # Default: logstash-
      [--to=TO]                      # End date
                                     # Default: 2012-05-11
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

## TODO

- find a way to query existing instances
- specify last 15m 
- find a way to get the results by streaming instead of loading all in memory (maybe pagination will help here)
- export to json, raw format
- a way specify the fields to include in the output
