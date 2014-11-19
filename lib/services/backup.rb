class DeliciousBackupService

	attr_reader :delicious_api, :options

	def initialize(delicious_api, options)
		@delicious_api = delicious_api
		@options = options
	end

	def get_delicious_uri
	end

	def get_delicious_data
		posts = delicious_api.get_all_posts options[:tags]

		File.open("delicious-backup-#{Time.now.strftime("%F_%H-%M-%S")}.yml", "w") do |f|
			f.write(posts.to_yaml)
		end

		{
			:headers => nil,
			:payload => posts
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
	end

	def print_report_status(data)
		puts "Found (#{data[:payload].size}) posts."
  		puts
	end
end