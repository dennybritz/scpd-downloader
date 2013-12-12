# encoding: utf-8

require 'mechanize'
require 'LoginController'
require 'VideoDownloader'
require 'VideoController'

# Downloads videos according to options specified
class DownloadController
  CUR_QUARTER_URL = 'https://myvideosu.stanford.edu/oce/currentquarter.aspx'
  BASE_URL = 'https://myvideosu.stanford.edu'
  SL_PLAYER_URL = 'http://myvideosv.stanford.edu/player/slplayer.aspx'
  SL_HASH_URL = 'https://myvideosu.stanford.edu/OCE/GradCourseInfo.' +
    'aspx/playSLVideo'

  public

  def initialize(options = {})
    @options = options
  end

  def download_one(course, filename, lecture_num)
    agent = get_mechanize_agent

    # login
    login_controller = LoginController.new
    login_controller.login agent

    # get video url
    video_controller = VideoController.new
    video_url = video_controller.get_video_url course, lecture_num, agent

    # download the video
    video_downloader = VideoDownloader.new(@options)
    video_downloader.fetch_video video_url, filename
  end

  private

  def get_mechanize_agent
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    agent.robots = false

    agent
  end
end
