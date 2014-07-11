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

	def get_tags_uri
		"#{@@API}tags/get"
	end

	def get_tags
		response = request(get_tags_uri)
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