#! /usr/bin/env ruby

require "optparse"
require "mechanize"
require "json"
require "io/console"

BASE_URL = "https://myvideosu.stanford.edu/"
CURRENT_QUARTER_URL = "https://myvideosu.stanford.edu/oce/currentquarter.aspx"

# Parse command options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: scpd_downloader.rb [course] [lecture_num] [filename] [options]"
  opts.on("-l", "--link", "Print raw video link instead of downloading the lecture.") do |links|
    options[:link] = links
  end
end.parse!

# Parse command argument
COURSE = ARGV.shift
LECTURE_NUM = (ARGV.shift || 1).to_i - 1
FILENAME = ARGV.shift || "output.mp4"

agent = Mechanize.new
agent.user_agent_alias = "Mac Safari"
agent.robots = false

# Load cookies if available
if File.exist?("cookies")
  agent.cookie_jar.load("cookies", :session => true, :format => :yaml)
end

# Fetch the page
page = agent.get(CURRENT_QUARTER_URL)

# Fill out the login form
while (page.form("login") && !(page.content =~ /Two-step authentication/))
  login_form = page.form("login")
  print "SUNet ID: "
  login_form.username = gets.strip
  print "SUNet Password: "
  login_form.password = STDIN.noecho(&:gets).strip
  login_form.checkboxes.first.checked = true
  puts "\nLogging in..."
  page = agent.submit(login_form, login_form.buttons.first)
end

# If asked for two-step authentication
if page.content =~ /Two-step authentication/
  print "Two-step authentication code: "
  login_form = page.form("login")
  login_form.otp = gets.strip
  page = agent.submit(login_form, login_form.buttons.first)
end

# Save cookies
agent.cookie_jar.save_as("cookies", :session => true, :format => :yaml)

# Find the course number and visit the course page
course_url = page.content  =~ /href=\"(.*#{COURSE}.*?)\"/i && (BASE_URL + $1)
if $1
  page = agent.get(course_url)
else
  $stderr.puts "course #{COURSE} was not found on #{CURRENT_QUARTER_URL}"
  exit 1
end

# Visit the player page for the specified lecture
lecture_link = page.links.select { |link| link.text == "SL"}.reverse[LECTURE_NUM]
if lecture_link.nil?
  $stderr.puts "lecture ${LECTURE_NUM} was not found"
  exit 1
else
  lecture_link.href =~ /javascript:openSL\((.*?)\);/
  coll, course, co, lecture, lectureDesc, authtype, playerType = *($1.gsub("\"","").to_s.split(","))
end

# Get the SLP hash for authentication via JSON request
json_response = agent.post("https://myvideosu.stanford.edu/OCE/GradCourseInfo.aspx/playSLVideo",
  {:coGuidstr => co, :collGuidstr => coll, :desiredAuthType => "WA"}.to_json, 
  "Content-Type" => "application/json;")
slp = JSON(json_response.body)["d"]
player_url = "http://myvideosv.stanford.edu/player/slplayer.aspx?" + 
  "coll=#{coll}&course=#{course}&co=#{co}&lecture=#{lecture}&authtype=#{authtype}&slp=#{slp}&sl=true"
page = agent.get(player_url)

# Get the video URL and download using avconv
video_url = page.content =~ /(mms:\/\/.*\.wmv)/ && $1
video_url.gsub!("mms","mmsh")
if options[:link]
  puts video_url
else
  system("avconv -y -i #{video_url} -strict experimental #{FILENAME}")
end
