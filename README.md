# Stanford SCPD Lecture Downloader

Downloads lecture videos from [https://myvideosu.stanford.edu/oce/currentquarter.aspx](https://myvideosu.stanford.edu/oce/currentquarter.aspx). You need a valid Stanford SUNet ID. Supports two-step authentication. Videos are streamed, so downloading lectures may take a while.

I wrote this script in a hurry, so there is absolutely no error handling. This means it'll crash if you give it a wrong lecture number, course, or login credentials. Garbage in, garbage out. Pull requests are welcome.

## System requirements

- Ruby 1.9.3 or higher (I recommend using [rbenv](https://github.com/sstephenson/rbenv))
- JSON gem (`gem install json`)
- [Mechanize gem](http://mechanize.rubyforge.org/) (`gem install mechanize`)
- [ffmpeg](http://www.ffmpeg.org/) (`brew install ffmpeg`)

## Usage

```shell
./scpd_downloader.rb [course] [lecture_number] [filename]
```
For example:
```shell
./scpd_downloader.rb cs229 1 cs229-01.mp4
```

## TODO

- Error handling in case of:
  - Incorrect login credentials
  - Incorrect two-step authentication code
  - Incorrect course name
  - Incorrect lecture number
- Specifying "last" as a lecture number should translate the lecture number to -1

