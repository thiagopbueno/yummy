class DeliciousDatesService

	attr_reader :delicious_api, :options

	def initialize(delicious_api, options)
		@delicious_api = delicious_api
		@options = options
	end

	def get_delicious_uri
		delicious_api.get_posts_dates_uri options[:tags]
	end

	def get_delicious_data
		dates = delicious_api.get_posts_dates options[:tags]
		{
			:headers => nil,
			:payload => dates.sort{|a, b| b <=> a}
		}
	end

	def print_data_entry(index, key, value)
		puts "[#{index}]\tdate: #{key}\tcount: #{value}" unless index > options[:max]
	end

	def print_report_header(headers)
	end

	def print_report_status(data)
		n = data[:payload].size < options[:max] ? data[:payload].size : options[:max]
		puts
		puts "Found (#{data[:payload].size}) post dates. Shown only first (#{n})."
		puts "URL: #{get_delicious_uri}"
		puts
	end
end