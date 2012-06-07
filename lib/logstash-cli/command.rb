require 'logstash-cli/command/grep'
require 'logstash-cli/command/tail'

module LogstashCli::Command
  include Grep
  include Tail
end
