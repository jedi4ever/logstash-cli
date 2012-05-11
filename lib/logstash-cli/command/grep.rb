require 'date'

module LogstashCli::Command

  def _grep(pattern,options)
    es_url = options[:esurl]
    index_prefix =  options[:index_prefix]

    from = options[:from]
    to  = options[:to]

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
      puts "Something went wrong while parsing the dates: currently only dates are supported with last. Be sure to add the suffix 'd' "+ex
      exit -1
    end

    (from_date..to_date).to_a.each do |date|
      es_index = index_prefix+date.to_s.gsub('-','.')

      result_size = options[:size]
      puts "Searching #{es_url}[#{es_index}] - #{pattern}"

      begin
        Tire.configure {url es_url}
        search = Tire.search(es_index) do
          query do
            string "#{pattern}"
            #must { string "facility:#{opts[:facility]}" } unless opts[:facility].nil?
            #must { string "_logger:#{opts[:class_name]}" } unless opts[:class_name].nil?
            #must { string "full_message:Exception*" } if opts[:exceptions]
          end
          sort do
            by :@timestamp, 'desc'
          end
          size result_size
        end
      rescue Exception => e
        puts e
        puts "\nSomething went wrong with the search. This is usually due to lucene query parsing of the 'grep' option"
        exit
      end

      require 'pp'
      begin
        search.results.sort {|a,b| a[:@timestamp] <=> b[:@timestamp] }.each do |res|

          pp res
          # service = res[:@fields][:facility]
          # class_name = res[:@fields][:_logger]
          # file = res[:@fields][:file]
          # #msg = res[:@fields][:full_message]
          # msg = res[:@fields][:message]
          tstamp = Time.iso8601(res[:@timestamp]).localtime.iso8601
          # fields = opts[:fields] || ["tstamp", "service", "msg"]
          # vals = fields.map {|x| x == fields[0] ? "\\e[1m[#{eval(x)}]\\e[0m" : eval(x)}
          # display = vals.join(" - ")
          # puts display

        end
      rescue ::Tire::Search::SearchRequestFailed => e
        puts e.message
      end
    end
  end
end
