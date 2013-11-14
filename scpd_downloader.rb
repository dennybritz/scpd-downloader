#! /usr/bin/env ruby

# Usage: ./scpd_downloader [course] [lecture_num] [filename]
# Usage: ./scpd_downloader cs229 1 cs229-01.mp4


require "optparse"
require "mechanize"
require "json"
require "io/console"

BASE_URL = "https://myvideosu.stanford.edu/"
CURRENT_QUARTER_URL = "https://myvideosu.stanford.edu/oce/currentquarter.aspx"
COURSE = ARGV.shift
LECTURE_NUM = (ARGV.shift || 1).to_i - 1
FILENAME = ARGV.shift || "output.mp4"

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: scpd_downloader.rb [course] [lecture_num] [filename] [options]"
  opts.on("-u", "--user USER", "SUNet user id") do |user|
    options[:user] = user
  end
  opts.on("-p", "--password PASSWORD", "SUNET password") do |pass|
    options[:password] = pass
  end
end.parse!

puts "Downloading lecture #{LECTURE_NUM + 1} for course #{COURSE}"

agent = Mechanize.new
agent.user_agent_alias = "Mac Safari"
agent.robots = false

# Load cookies if available
if File.exist?("cookies")
  agent.cookie_jar.load "cookies", session: true, format: :yaml
end

page = agent.get(CURRENT_QUARTER_URL)

# Fill out the login form
if (page.form("login") && !(page.content =~ /Two-step authentication/))
  login_form = page.form("login")
  print "SUNet ID: "
  login_form.username = gets.strip
  # login_form.username = options[:user] || gets.strip
  print "SUNet Password: "
  login_form.password = STDIN.noecho(&:gets).strip
  # login_form.password = options[:password] || STDIN.noecho(&:gets).strip
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
agent.cookie_jar.save_as "cookies", session: true, format: :yaml

# Find the course number and visit the course page
course_url = page.content  =~ /href=\"(.*#{COURSE}.*?)\"/i && (BASE_URL + $1)
page = agent.get(course_url)

# Visit the player page for the specified lecture
page.links.select { |link| link.text == "SL"}.reverse[LECTURE_NUM].href =~ /javascript:openSL\((.*?)\);/ 
coll, course, co, lecture, lectureDesc, authtype, playerType = *($1.gsub("\"","").split(","))

# Get the SLP hash for authentication via JSON request
json_response = agent.post("https://myvideosu.stanford.edu/OCE/GradCourseInfo.aspx/playSLVideo", 
  {coGuidstr: co, collGuidstr: coll, desiredAuthType: "WA"}.to_json, "Content-Type" => "application/json;")
slp = JSON(json_response.body)["d"]
player_url = "http://myvideosv.stanford.edu/player/slplayer.aspx?coll=#{coll}&course=#{course}&co=#{co}&lecture=#{lecture}&authtype=#{authtype}&slp=#{slp}&sl=true"
page = agent.get(player_url)

# Get the video URL and download using mimms
video_url = page.content =~ /(mms:\/\/.*\.wmv)/ && $1
system("ffmpeg -i #{video_url.gsub("mms","mmsh")} #{FILENAME}")
