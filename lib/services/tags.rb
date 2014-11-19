class DeliciousTagsService

	attr_reader :delicious_api, :options

	def initialize(delicious_api, options)
		@delicious_api = delicious_api
		@options = options
	end

	def get_delicious_uri
		delicious_api.get_tags_uri
	end

	def get_delicious_data
		tags = delicious_api.get_tags
		{
			:headers => nil,
			:payload => tags
		}
	end

	def print_data_entry(index, key, value)
		puts "[#{index}]\tcount: #{value}\ttag: #{key}" unless index > options[:max]
	end

	def print_report_header(headers)
	end

	def print_report_status(data)
		n = data[:payload].size < options[:max] ? data[:payload].size : options[:max]
		puts
		puts "Found (#{data[:payload].size}) tags. Shown only first (#{n})."
		puts "URL: #{get_delicious_uri}"
		puts
	end
end