require 'logstash-cli/command/grep'
require 'logstash-cli/command/tail'
require 'logstash-cli/command/count'

module LogstashCli
  module Command
    include Grep
    include Tail
    include Count

    def _format(result,options)
      output = case options[:format]
                 when 'csv' then result.to_csv({:col_sep => options[:delim]})
                 when 'json' then result.to_json
                 when 'plain' then result.join(options[:delim])
               end
      return output
    end
  end
end
