#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'logger'
require 'yaml'
require 'rexml/document'
require 'optparse'


API = "https://api.del.icio.us/v1/"

# Parse command line options
options = {:object => "posts", :tags => "programming", :max => 5}

opt_parser = OptionParser.new do |opts|
  opts.banner =   "Usage: ./yummy.rb [OPTIONS]"
  opts.separator  ""
  opts.separator  "OPTIONS"

  opts.on("-o", "--object (tags|posts)", "Choose between list of 'tags' or 'posts'") do |d|
    options[:object] = d
  end

  opts.on("-t", "--tags tag1+tag2+...", "Set list of tags (separated by '+') for posts") do |d|
    options[:tags] = d
  end

  opts.on("-n", "--max MAX", "Set maximum number of tags/posts") do |d|
    options[:max] = d.to_i
  end

  opts.on("-s", "--start-date START_DATE", "Set start date for all API requests") do |d|
    options[:start] = Date.parse(d).strftime("%FT%TZ")
  end

  opts.on("-e", "--end-date END_DATE", "Set end date for all API requests") do |d|
    options[:end] = Date.parse(d).strftime("%FT%TZ")
  end

  opts.on("-h", "--help", "Display this information") do
    puts opt_parser
    exit 0
  end

  opts.separator  ""
  opts.separator  "** All dates must be provided in the format `YYYY-MM-DD'"
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
if options[:object] == "tags"
  request = "#{API}tags/get"
else
  request = "#{API}posts/all?tag=#{options[:tags]}&results=#{options[:max]}"

  unless options[:start].nil?
    request += "&fromdt=#{options[:start]}"
  end

  unless options[:end].nil?
    request += "&todt=#{options[:end]}"
  end
end

page = begin
  agent.post(request, {}, {"Authorization" => "Bearer #{ACCESS_TOKEN}"})
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

  if options[:object] == "tags"
    i = 1
    doc.elements.each("tags/tag") do |element|
      if i <= options[:max]
        count = element.attributes["count"]
        tag = element.attributes["tag"]
        puts "[#{i}]\tcount: #{count}\ttag: #{tag}"
      end
      i += 1
    end

    n = i < options[:max] ? i : options[:max]
    puts
    puts "Found (#{i}) tags. Shown only first (#{n})."
    puts "URL: #{request}"
    puts

  end

  if options[:object] == "posts"
    tag = doc.elements[1].attributes["tag"]
    total = doc.elements[1].attributes["total"]
    user = doc.elements[1].attributes["user"]

    puts "User `#{user}' has #{total} posts."
    puts

    i = 1
    doc.elements.each("posts/post") do |element|
      description = element.attributes["description"]
      href = element.attributes["href"]
      time = element.attributes["time"]
      tags = element.attributes["tag"]

      puts "[#{i}]\t#{description} @ #{time}"
      puts ">> #{href}"
      puts "tags: #{tags}"
      puts

      i += 1
    end

    puts
    puts "Found (#{i-1}) posts for tag(s) `#{options[:tags]}'."
    puts "URL: #{request}"
    puts

  end
end