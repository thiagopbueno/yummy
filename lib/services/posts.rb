class DeliciousPostsService

	attr_reader :delicious_api, :options

	def initialize(delicious_api, options)
		@delicious_api = delicious_api
		@options = options
	end

	def get_delicious_uri
		delicious_api.get_posts_uri(options[:tags], options[:max], nil, options[:start], options[:end])
	end

	def get_delicious_data
		posts = delicious_api.get_posts(options[:tags], options[:max], nil, options[:start], options[:end])
		{
			:headers => {:user => posts["info"]["user"], :total => posts["info"]["total"]},
			:payload => posts["posts"]
		}
	end

	def print_data_entry(index, key, value)
		desc = value["desc"]
	    href = value["href"]
	    tags = value["tags"]
	    time = value["dt"]

	    puts "[#{index}]\t\t#{desc}"
	    puts "#{time[0, 10]}\thref: #{href}"
	    puts "#{time[11..-1]}\ttags: #{tags}"
	    puts
	end

	def print_report_header(headers)
		puts "User `#{headers[:user]}' has #{headers[:total]} posts." unless options[:tags]
		puts
	end

	def print_report_status(data)
		puts "Found (#{data[:payload].size}) posts for tag(s) `#{options[:tags]}'." if options[:tags]
		puts "URL: #{get_delicious_uri}"
		puts
	end
end
