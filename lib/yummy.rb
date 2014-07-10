#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'logger'
require 'yaml'
require 'rexml/document'
require 'optparse'


API = "https://api.del.icio.us/v1/"

# Parse command line options
options = {:tags => "programming", :max => 10}

opt_parser = OptionParser.new do |opts|
  opts.banner =   "Usage: ./yummy.rb [OPTIONS]"
  opts.separator  ""
  opts.separator  "OPTIONS"

  opts.on("-t", "--tags TAGS", "Set tags for posts") do |d|
    options[:tags] = d
  end

  opts.on("-n", "--max MAX", "Set maximum number of posts") do |d|
    options[:max] = d
  end

  opts.on("-s", "--start-date START_DATE", "Set start date for all API requests") do |d|
    options[:start] = d
  end

  opts.on("-e", "--end-date END_DATE", "Set end date for all API requests") do |d|
    options[:end] = d
  end

  opts.on("-h", "--help", "Display this information") do
    puts opt_parser
    exit 0
  end

  opts.separator  ""
  opts.separator  "** All dates must be provided in the format `yyyy-mm-dd'"
  opts.separator  ""
end
opt_parser.parse!


# Greet user
puts "Hello, Yummy! You're just looking delicious ..."

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
  agent.post("#{API}posts/all?tag=#{options[:tags]}&results=#{options[:max]}", {}, {"Authorization" => "Bearer #{ACCESS_TOKEN}"})
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

  puts "Found posts for tags `#{tag}' ..."
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