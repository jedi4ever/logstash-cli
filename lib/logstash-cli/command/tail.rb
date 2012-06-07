require 'yajl/json_gem'

module Tail

  def _tail(options)
    amqp_url = options[:amqpurl]
    exchange_name = options[:exchange]
    routing_key = options[:key]
    metafields = options[:meta].split(',')

    AMQP.start(amqp_url) do |connection, open_ok|
      channel = AMQP::Channel.new(connection, :auto_recovery => true)

      channel.queue("", :auto_delete => true, :durable => false) do |queue, declare_ok|
        queue.bind(exchange_name, :routing_key => routing_key)
        queue.subscribe do |payload|
          parsed_message = JSON.parse(payload)
          result = Array.new

          metafields.each do |metafield|
            result << parsed_message["@#{metafield}"]
          end

          output = case options[:format]
                   when 'csv' then result.to_csv({:col_sep => options[:delim]})
                   when 'json' then result.to_json
                   end

          puts output
          result = []
        end
      end

      trap("INT") { puts "Shutting down..."; connection.close { EM.stop };exit }
    end
  end
end
