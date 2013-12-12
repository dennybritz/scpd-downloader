# encoding: utf-8

require 'io/console'
require 'mechanize'
require 'json'
require 'cgi'
require 'LoginController'
require 'VideoDownloader'

# Downloads videos according to options specified
class VideoDownloader

  public

  def initialize(options = {})
    @options = options
  end

  def fetch_video(video_url, filename)
    if @options[:link]
      puts video_url
    else
      system("ffmpeg -i #{video_url} #{filename}")
    end
  end
end
