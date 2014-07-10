#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'logger'
require 'yaml'
require 'rexml/document'

puts "Hello, Yummy! You're just looking delicious ..."

API = "https://api.del.icio.us/v1/"

# Load ACCESS_TOKEN
config = begin
  YAML.load(File.open("../config.yml"))
rescue ArgumentError => e
  puts "Could not parse YAML: #{e.message}"
end
ACCESS_TOKEN = config['ACCESS_TOKEN']

# Initialize mechanize agent
agent = Mechanize.new do |agent|
  agent.user_agent_alias = "Mac Mozilla"
  agent.log = Logger.new "mechanize.log"
end

# Get resource from Delicious API
page = begin
  agent.post("#{API}posts/all?tag=programming&results=5", {}, {"Authorization" => "Bearer #{ACCESS_TOKEN}"})
rescue Mechanize::ResponseCodeError => exception
  puts exception.inspect if exception.respond_to? :inspect
end

# Print results
unless page.nil?
  include REXML
  doc = Document.new page.body
	# out = ""
	# doc.write(out, 4)
  # puts out

  tag = doc.elements[1].attributes["tag"]
  total = doc.elements[1].attributes["total"]
  user = doc.elements[1].attributes["user"]
  
  puts "User `#{user}' has #{total} posts."
  puts

  puts "Found posts for tag `#{tag}' ..."
  puts

  doc.elements.each("posts/post") do |element|
    description = element.attributes["description"]
    href = element.attributes["href"]
    time = element.attributes["time"]
    tag = element.attributes["tag"]

    puts "#{time}: #{description}"
    puts ">> #{href}"
    puts "tags: #{tag}"
    puts
  end
end