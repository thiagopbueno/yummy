require 'mechanize'
require 'logger'
require 'rexml/document'
include REXML


class DeliciousAPI

	@@API = "https://api.del.icio.us/v1/"

	def initialize(code)
		@access_token = code

		# Initialize mechanize agent
		@agent = Mechanize.new do |agent|
		  agent.user_agent_alias = "Mac Mozilla"
		  agent.log = Logger.new "mechanize.log"
		end
	end


	# /v1/tags/get
	# https://github.com/SciDevs/delicious-api/blob/master/api/tags.md#v1tagsget
	def get_tags_uri
		"#{@@API}tags/get"
	end

	def get_tags
		uri = get_tags_uri
		response = request uri
		return nil if response.nil?
		
		doc = Document.new response.body

		tags = {}
		doc.elements.each("tags/tag") do |element|
      count = element.attributes["count"]
      tag   = element.attributes["tag"]
      
      tags[tag] = count
 		end
 		
 		tags
	end

	# /v1/posts/all?
	# https://github.com/SciDevs/delicious-api/blob/master/api/posts.md#v1postsall
	def get_posts_uri(tags, max, start_date, end_date)
		uri = "#{@@API}posts/all?tag=#{tags}&results=#{max}"
		uri += "&fromdt=#{start_date}" unless start_date.nil?
		uri += "&todt=#{end_date}"     unless end_date.nil?
		uri
	end

	def get_posts(tags, max, start_date, end_date)
		uri = get_posts_uri tags, max, start_date, end_date
		response = request uri
		return nil if response.nil?

		doc = Document.new response.body
	  # out = ""
	  # doc.write(out, 4)
  	# puts out

    user = {
    	:user  => doc.elements[1].attributes["user"],
    	:total => doc.elements[1].attributes["total"],
    	:tag   => doc.elements[1].attributes["tag"]
    }

    posts = {}
    doc.elements.each("posts/post") do |element|
      posts[element.attributes["hash"]] = {
      	:desc => element.attributes["description"],
      	:href => element.attributes["href"],
      	:tags => element.attributes["tag"],
      	:dt   => element.attributes["time"]
      }
    end

    {:info => user, :posts => posts}
	end

	# /v1/posts/dates?
	# https://github.com/SciDevs/delicious-api/blob/master/api/posts.md#v1postsdates
	def get_posts_dates_uri(tag)
		uri = "#{@@API}posts/dates"
		uri += "?tag=#{tag}" unless tag.nil?
		uri
	end

	def get_posts_dates(tag)
		uri = get_posts_dates_uri tag
		response = request uri
		return nil if response.nil?

		doc = Document.new response.body

		dates = {}
		doc.elements.each("dates/date") do |element|
			dt    = element.attributes["date"]
			count = element.attributes["count"]

			dates[dt] = count
		end

		dates
	end

private
	def request(uri)
		page = begin
		  @agent.post(uri, {}, {"Authorization" => "Bearer #{@access_token}"})
		rescue Mechanize::ResponseCodeError => exception
		  puts exception.inspect if exception.respond_to? :inspect
		  return nil
		end
		page
	end

end