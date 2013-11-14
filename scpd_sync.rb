#! /usr/bin/env ruby

# Usage: ./scpd_sync [COURSE] [OUTPUT)DIR] -u [USER] -o [PASSWORD]

require "optparse"

BASE_URL = "https://myvideosu.stanford.edu/"
CURRENT_QUARTER_URL = "https://myvideosu.stanford.edu/oce/currentquarter.aspx"
COURSE = ARGV.shift
DESTINATION_DIR = ARGV.shift
MIN_LECTURE = 1
MAX_LECTURE = 40

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: scpd_sync.rb [course] [destination_directory] [options]"
  opts.on("-f", "--force", "Download all lectures and overwrite existing files") do |force|
    options[:force] = force
  end
  opts.on("-u", "--user USER", "SUNet user id") do |user|
    options[:user] = user
  end
  opts.on("-p", "--password PASSWORD", "SUNET password") do |pass|
    options[:password] = pass
  end
end.parse!

MIN_LECTURE.upto(MAX_LECTURE).each do |lecture_num|
  puts "Requesting lecture #{lecture_num}"
  filename = "#{DESTINATION_DIR}/#{lecture_num}.mp4"
  system("./scpd_downloader.rb #{COURSE} #{lecture_num} #{filename} --user #{options[:user]} --password #{options[:password]}")
end