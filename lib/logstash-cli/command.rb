require 'logstash-cli/command/grep'
require 'logstash-cli/command/tail'

module LogstashCli
  module Command
    include Grep
    include Tail
  end
end
