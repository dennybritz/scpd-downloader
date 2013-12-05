#! /usr/bin/env ruby

# Usage: ./scpd_downloader [course] [lecture_num] [filename]
# Usage: ./scpd_downloader cs229 1 cs229-01.mp4


require "optparse"
require "mechanize"
require "json"
require "io/console"

BASE_URL = "https://myvideosu.stanford.edu"
CURRENT_QUARTER_URL = "https://myvideosu.stanford.edu/oce/currentquarter.aspx"
COURSE = ARGV.shift

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: scpd_downloader.rb [course] [lecture_num] [options]"
  opts.on("-l", "--link", "Print raw video link instead of downloading the lecture.") do |links|
    options[:link] = links
  end
end.parse!
puts options
LECTURE_NUM = ARGV.shift

if not LECTURE_NUM.nil?
    LECTURE_NUM = LECTURE_NUM.to_i - 1
    puts "Downloading lecture #{LECTURE_NUM + 1} for course #{COURSE}"
else
    puts "Downloading all lectures for course #{COURSE}"
end

agent = Mechanize.new
agent.user_agent_alias = "Mac Safari"
agent.robots = false

# Load cookies if available
if File.exist?("cookies")
  agent.cookie_jar.load "cookies", session: true, format: :yaml
end

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
agent.cookie_jar.save_as "cookies", session: true, format: :yaml
page = agent.click(page.link_with(:text => BASE_URL))
# Find the course number and visit the course page
course_url = page.content  =~ /href=\"(.*#{COURSE}.*?)\"/i && (BASE_URL + $1)


def download(link, agent, options)
    link.href =~ /javascript:openSL\((.*?)\);/
    coll, course, co, lecture, lectureDesc, authtype, playerType = *($1.gsub("\"","").split(","))
    fname = "#{course}_#{lecture}.wmv"
    if File.exist?(fname)
        puts "File already exists #{fname}"
        return
    else 
        puts "Downloading #{fname}"
    end
    # Get the SLP hash for authentication via JSON request
    json_response = agent.post("https://myvideosu.stanford.edu/OCE/GradCourseInfo.aspx/playSLVideo", 
                               {coGuidstr: co, collGuidstr: coll, desiredAuthType: "WA"}.to_json, "Content-Type" => "application/json;")
    slp = JSON(json_response.body)["d"]
    player_url = "http://myvideosv.stanford.edu/player/slplayer.aspx?coll=#{coll}&course=#{course}&co=#{co}&lecture=#{lecture}&authtype=#{authtype}&slp=#{slp}&sl=true"
    page = agent.get(player_url)

    # Get the video URL and download using mimms
    video_url = page.content =~ /(mms:\/\/.*\.wmv)/ && $1
    video_url.gsub!("mms","mmsh")


    if options[:link]
      puts video_url
    else
      system("ffmpeg -i #{video_url} #{fname}")
    end
end


page = agent.get(course_url)
links = page.links.select { |link| link.text == "SL" }.reverse
if not LECTURE_NUM.nil?
    links = [links[LECTURE_NUM]]
end

for link in links
    puts link.href
    begin 
        download(link, agent, options)
    rescue Exception => e
        puts "Failed to download"
        puts e
    end
end


