require 'date'

require 'yajl/json_gem'

module LogstashCli::Command

  def _grep(pattern,options)
    es_url = options[:esurl]
    index_prefix =  options[:index_prefix]

    from = options[:from]
    to  = options[:to]
    metafields = options[:meta].split(',')
    fields = options[:fields].split(',')

    begin
      unless options[:last].nil?
        days = options[:last].match(/(\d*)d/)[1].to_i
        to_date = Date.today
        from_date = to_date - days
        from = from_date.to_s
        to = to_date.to_s
      end

      from_date = Date.parse(from)
      to_date = Date.parse(to)
    rescue Exception => ex
      $stderr.puts "Something went wrong while parsing the dates: currently only dates are supported with last. Be sure to add the suffix 'd' "+ex
      exit -1
    end

    $stderr.puts "Searching #{es_url}[#{index_prefix}#{from_date}..#{index_prefix}#{to_date}] - #{pattern}"

    (from_date..to_date).to_a.each do |date|
      es_index = index_prefix+date.to_s.gsub('-','.')

      result_size = options[:size]

      begin
        Tire.configure {url es_url}
        search = Tire.search(es_index) do
          query do
            string "#{pattern}"
          end
          sort do
            by :@timestamp, 'desc'
          end
          size result_size
        end
      rescue Exception => e
        $stderr.puts e
        $stderr.puts "\nSomething went wrong with the search. This is usually due to lucene query parsing of the 'grep' option"
        exit
      end

      begin
        result = Array.new
        search.results.sort {|a,b| a[:@timestamp] <=> b[:@timestamp] }.each do |res|

          metafields.each do |metafield|
            result << res["@#{metafield}".to_sym]
          end

          fields.each do |field|
            result << res[:@fields][field.to_sym]
          end

          output = case options[:format]
            when 'csv' then result.to_csv({:col_sep => options[:delim]})
            when 'json' then result.to_json
          end
          #tstamp = Time.iso8601(res[:@timestamp]).localtime.iso8601

          puts output
          result = []
        end
      rescue ::Tire::Search::SearchRequestFailed => e
        $stderr.puts e.message
      end
    end
  end
end
