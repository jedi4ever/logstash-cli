require 'date'

require 'yajl/json_gem'

module Grep

  def self.indexes_from_interval(from, to)
    (from.to_date..to.to_date).sort.map do |date|
      date.to_s.gsub('-', '.')
    end
  end

  # Very naive time range description parsing.
  def self.parse_time_range(desc)
    /(?<value>\d+)\s*(?<units>\w*)/ =~ desc
    value = value.to_i
    start = case units.to_s.downcase
            when 'm', 'min', 'mins', 'minute', 'minutes'
              DateTime.now - (value/(60*24.0))
            when 'h', 'hr', 'hrs', 'hour', 'hours'
              DateTime.now - (value/24.0)
            when 'd', 'day', 'days'
              DateTime.now - value
            when 'w', 'wk', 'wks', 'week', 'weeks'
              DateTime.now - (7.0*value)
            when 'y', 'yr', 'yrs', 'year', 'years'
              DateTime.now - (365.0*value)
            else
              raise ArgumentError
            end
    [start, DateTime.now]
  end

  def _grep(pattern,options)
    es_url = options[:esurl]
    index_prefix =  options[:index_prefix]
    metafields = options[:meta].split(',')
    fields = options[:fields].split(',')

    begin
      if options[:last].nil?
        from_time = DateTime.parse(options[:from])
        to_time = DateTime.parse(options[:to])
      else
        from_time, to_time = Grep.parse_time_range(options[:last])
      end
    rescue ArgumentError
      $stderr.puts "Something went wrong while parsing the date range."
      exit -1
    end

    index_range = Grep.indexes_from_interval(from_time, to_time).map do |i|
      "#{index_prefix}#{i}"
    end

    $stderr.puts "Searching #{es_url}[#{index_range.first}..#{index_range.last}] - #{pattern}"

    # Reformat time interval to match logstash's internal timestamp'
    from = from_time.to_time.utc.strftime('%FT%T')
    to = to_time.to_time.utc.strftime('%FT%T')

    # Total of results to show
    total_result_size = options[:size]

    # For this index the number of results to show
    # Previous indexes might already have generate results

    running_result_size = total_result_size.to_i

    # We reverse the order of working ourselves through the index
    index_range.reverse.each do |idx|
      begin
        Tire.configure {url es_url}
        search = Tire.search(idx) do
          query do
            string "#{pattern}"
          end
          sort do
            by :@timestamp, 'desc'
          end
          filter "range", "@timestamp" => { "from" => from, "to" => to}
          size running_result_size
        end
      rescue Exception => e
        $stderr.puts e
        $stderr.puts "\nSomething went wrong with the search. This is usually due to lucene query parsing of the 'grep' option"
        exit
      end

      begin
        result = Array.new

        # Decrease the number of results to get from the next index
        running_result_size -= search.results.size

        search.results.sort {|a,b| a[:@timestamp] <=> b[:@timestamp] }.each do |res|

          metafields.each do |metafield|
            result << res["@#{metafield}".to_sym]
          end

          fields.each do |field|
            result << res[:@fields][field.to_sym]
          end

          puts _format(result, options)
          result = []
        end
      rescue ::Tire::Search::SearchRequestFailed => e
        # If we got a 404 it likely means we simply don't have logs for that day, not failing over necessarily.
        $stderr.puts e.message unless search.response.code == 404
      end
    end
  end
end
