require 'date'

require 'yajl/json_gem'

module Count

  def _count(pattern,options)
    es_url = options[:esurl]
    index_prefix = options[:index_prefix]

    from = options[:from]
    to = options[:to]
    metafields = options[:meta].split(',')
    fields = options[:fields].split(',')

    countfield = options[:countfield]
    countsize = options[:countsize]

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

    # We reverse the order of working ourselves through the index
    (from_date..to_date).sort.reverse.to_a.each do |date|

      es_index = index_prefix+date.to_s.gsub('-','.')

      begin
        Tire.configure {url es_url}
        search = Tire.search(es_index) do
          query do
            string "#{pattern}"
          end
          facet "#{countfield}" do
             terms countfield, :size => countsize
          end
        end
      rescue Exception => e
        $stderr.puts e
        $stderr.puts "\nSomething went wrong with the search. This is usually due to lucene query parsing"
        exit
      end

      # Results per index to show
      result_size = options[:size]

      begin
        results = search.results.facets[countfield]

        header = [ countfield, results['total'] ]
        puts _format(header, options)

        results['terms'].each do |terms|
          puts _format(terms.values, options)

          unless fields.empty? and metafields.empty?
            term = terms['term']
            begin
              Tire.configure {url es_url}
              search = Tire.search(es_index) do
                query do
                  string "#{pattern}"
                end
                filter :terms, countfield => [term]
                size result_size
              end
            rescue Exception => e
              $stderr.puts e
              $stderr.puts "\nSomething went wrong with the search. This is usually due to lucene query parsing"
              exit
            end

            search.results.each do |log|
              result = Array.new

              metafields.each do |metafield|
                result << log["@#{metafield}".to_sym]
              end

              fields.each do |field|
                result << log[:@fields][field.to_sym]
              end

              puts _format(result, options)
              result = []
            end
          end
        end
      rescue ::Tire::Search::SearchRequestFailed => e
        $stderr.puts e.message
      end
    end
  end
end
