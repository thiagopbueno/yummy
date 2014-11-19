require_relative 'posts'
require_relative 'tags'
require_relative 'dates'
require_relative 'backup'

class ServiceFactory
	def self.build(type, delicious_api, options)
		service = nil

		if type == "tags"
		    service = DeliciousTagsService.new(delicious_api, options)
		elsif type == "dates"
		    service = DeliciousDatesService.new(delicious_api, options)
		elsif type == "posts"
		    service = DeliciousPostsService.new(delicious_api, options)
		elsif type == "backup"
		    service = DeliciousBackupService.new(delicious_api, options)
		end

		service
	end
end

class ServiceManager

	attr_reader :service

	def initialize(service)
		@service = service
	end

	def execute()
		data = service.get_delicious_data
	
		service.print_report_header(data[:headers])

		index = 1
		data[:payload].each do |key, value|
			service.print_data_entry(index, key, value)
			index += 1
		end if data[:payload]

		service.print_report_status(data)
	end
end