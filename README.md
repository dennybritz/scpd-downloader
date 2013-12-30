# Stanford SCPD Lecture Downloader

Downloads lecture videos from [https://myvideosu.stanford.edu/oce/currentquarter.aspx](https://myvideosu.stanford.edu/oce/currentquarter.aspx). **You need a valid Stanford SUNet ID.** Supports two-step authentication. Videos are streamed, so downloading lectures may take a while.

I wrote this script in a hurry, so there isn't much error handling. This means it may crash if you give it a wrong lecture number, course, or login credentials. Garbage in, garbage out. Pull requests are welcome.

**Distributing SCPD lectures is against the terms of service. This script is for private use only!**

## System requirements

- Ruby >= 1.9.3 (I recommend using [rbenv](https://github.com/sstephenson/rbenv))
- JSON gem (`gem install json`)
- [Mechanize gem](http://mechanize.rubyforge.org/) (`gem install mechanize`)
- [avconv](libav.org) (`brew install libav`)

## Usage

To download a lecture to a file: 

```shell
./scpd_downloader [course] [lecture_number] [filename]
```

```shell
./scpd_downloader cs229 1 cs229-01.mp4
```

Print the link for a lecture video to download it with another application: 

```shell
./scpd_downloader --link [course] [lecture_number]
```

```shell
./scpd_downloader --link cs229 1
```

## TODO

- Error handling in case of:
  - Incorrect login credentials
  - Incorrect two-step authentication code
