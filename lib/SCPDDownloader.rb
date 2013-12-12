# encoding: utf-8

require 'optparse'
require 'DownloadController'

# Runs scpd-downloader program
class SCPDDownloader
  USAGE = 'Usage: scpd_downloader.rb [course] [lecture_num] [filename] ' +
    '[options]'

  public

  def self.run
    course = ARGV.shift
    lecture_num = (ARGV.shift || 1).to_i - 1
    filename = ARGV.shift || 'output.mp4'
    options = parse_options

    downloader = DownloadController.new options
    downloader.download_one course, filename, lecture_num
  end

  private

  # Parse command line options
  def self.parse_options
    options = {}
    OptionParser.new do |opts|
      opts.banner = USAGE
      opts.on('-l', '--link',
              'Print raw video link instead of downloading the lecture.'
             ) do |links|
        options[:link] = links
      end
    end.parse!
    options
  end
end
