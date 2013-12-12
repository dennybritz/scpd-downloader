# encoding: utf-8

require 'json'

# Provides methods for getting a URL for a video stream
class VideoController

  CUR_QUARTER_URL = 'https://myvideosu.stanford.edu/oce/currentquarter.aspx'
  BASE_URL = 'https://myvideosu.stanford.edu'
  SL_PLAYER_URL = 'http://myvideosv.stanford.edu/player/slplayer.aspx'
  SL_HASH_URL = 'https://myvideosu.stanford.edu/OCE/GradCourseInfo.' +
    'aspx/playSLVideo'
  STREAM_LINK_REGEX = %r{(mms://.*\.wmv)}
  JS_STREAM_LINK_SCRAPER = /javascript:openSL\((.*?)\);/
  SILVERLIGHT_LINK_TEXT = 'SL'

  public

  def get_video_url(course, lecture_num, agent)
    lecture_link = get_lecture_link course, lecture_num, agent
    if lecture_link.nil?
      $stderr.puts 'No such lecture.'
      exit 1
    end
    player_url = get_player_url lecture_link, agent
    player_page = agent.get(player_url)

    # Get the video URL and download using mimms
    video_url = player_page.content.match(STREAM_LINK_REGEX)[0]
    video_url.gsub!('mms', 'mmsh')
  end

  private

  # convert hash of queries to a URI
  def make_query(base, queries)
    querystr = queries.map { |k, v| "#{k}=#{v.to_s}" }.join('&')
    base + '?' + querystr
  end

  # Find the course number and visit the course page
  def get_course_url(course, agent)
    splash_page = agent.get CUR_QUARTER_URL
    course_uri = splash_page.content.match(/href=\"(.*#{course}.*?)\"/i)[1]
    BASE_URL + course_uri
  end

  # Visit the player page for the specified lecture
  def get_lecture_link(course, lecture_num, agent)
    course_url = get_course_url course, agent
    course_page = agent.get(course_url)

    lecture_links = course_page.links.select do |link|
      link.text == SILVERLIGHT_LINK_TEXT
    end
    lecture_links.reverse[lecture_num]
  end

  # Get the SLP hash for authentication via JSON request
  def get_slp(coll, co, agent)
    arguments = { 'coGuidstr' => co, 'collGuidstr' => coll,
                  'desiredAuthType' => 'WA' }
    json_response = agent.post(
      SL_HASH_URL,
      arguments.to_json,
      'Content-Type' => 'application/json;')
    JSON(json_response.body)['d']
  end

  def get_player_url(lecture_link, agent)
    js_stream_parts = lecture_link.href.match(JS_STREAM_LINK_SCRAPER)[1]
    coll, course, co, lecture, _, authtype, _ =
      *(js_stream_parts.gsub('"', '').to_s.split(','))
    slp = get_slp coll, co, agent
    make_query(SL_PLAYER_URL, coll: coll, course: course, co: co, slp: slp,
                              lecture: lecture, authtype: authtype, sl: true)
  end
end
