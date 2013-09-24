#! /usr/bin/env ruby

# Usage: ./scpd_downloader [course] [lecture_num] [filename]
# Usage: ./scpd_downloader cs229 1 cs229-01.wmv

require "mechanize"
require "json"
require "io/console"

BASE_URL = "https://myvideosu.stanford.edu/"
CURRENT_QUARTER_URL = "https://myvideosu.stanford.edu/oce/currentquarter.aspx"
COURSE = ARGV.shift
LECTURE_NUM = (ARGV.shift || 1).to_i
FILENAME = ARGV.shift || "output.wmv"

puts "Downloading lecture #{LECTURE_NUM} for course #{COURSE}"

agent = Mechanize.new
agent.user_agent_alias = "Mac Safari"
agent.robots = false
page = agent.get(CURRENT_QUARTER_URL)

# Fill out the login form
login_form = page.form("login")
print "SUNet ID: "
login_form.username = gets.strip
print "SUNet Password: "
login_form.password = STDIN.noecho(&:gets).strip
login_form.checkboxes.first.checked = true
puts "\nLogging in..."
page = agent.submit(login_form, login_form.buttons.first)

# If asked for two-way authentication
if page.content =~ /Two-step authentication/
  print "Two-way authentication code: "
  login_form = page.form("login")
  login_form.otp = gets.strip
  page = agent.submit(login_form, login_form.buttons.first)
end

# Find the course number and visit the course page
course_url = page.content  =~ /href=\"(.*#{COURSE}.*?)\"/i && (BASE_URL + $1)
page = agent.get(course_url)

# Visit the player page for the specified lecture
page.links.select { |link| link.text == "SL"}[LECTURE_NUM - 1].href =~ /javascript:openSL\((.*?)\);/ 
coll, course, co, lecture, lectureDesc, authtype, playerType = *($1.gsub("\"","").split(","))

# Get the SLP hash for authentication via JSON request
json_response = agent.post("https://myvideosu.stanford.edu/OCE/GradCourseInfo.aspx/playSLVideo", 
  {coGuidstr: co, collGuidstr: coll, desiredAuthType: "WA"}.to_json, "Content-Type" => "application/json;")
slp = JSON(json_response.body)["d"]
player_url = "http://myvideosv.stanford.edu/player/slplayer.aspx?coll=#{coll}&course=#{course}&co=#{co}&lecture=#{lecture}&authtype=#{authtype}&slp=#{slp}&sl=true"
page = agent.get(player_url)

# Get the video URL and download using mimms
video_url = page.content =~ /(mms:\/\/.*\.wmv)/ && $1
return system("mimms -r #{video_url} #{FILENAME}")
