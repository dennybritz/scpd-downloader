#! /usr/bin/env ruby

COURSE = ARGV.shift
TARGET_DIR = "/#{ARGV.shift}/#{COURSE.downcase}"

1.upto(100).each do |i|
  lecture_num = "%0.2d" % i
  target_file = "#{TARGET_DIR}/#{lecture_num}.mp4"
  cmd = 
  link = `./scpd_downloader.rb #{COURSE} #{i} none --link`
  if link =~ /mmsh/
    puts "qsub -N #{COURSE}#{lecture_num} download.submit -y -i #{link.strip()} -strict experimental #{target_file}"
  else
    break
  end
end
