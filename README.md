# Stanford SCPD Lecture Downloader (2013)

Downloads lecture videos from `https://myvideosu.stanford.edu/oce/currentquarter.aspx`. You need a valid Stanford SUNet ID. Supports two-way authentication. Stanford limits the streaming bandwith to ~100kb/sec, so downloading lectures may take a while.

## System requirements

- Ruby 1.9.3 or higher (I recommend using [rbenv](https://github.com/sstephenson/rbenv))
- JSON gem (`gem install json`)
- [Mechanize gem](http://mechanize.rubyforge.org/) (`gem install mechanize`)
- [mimmms](http://savannah.nongnu.org/projects/mimms/) (`brew install mimms`)

## Usage

```shell
./scpd_downloader [course] [lecture_number] [filename]
# For example:
./scpd_downloader cs229 1 cs229-01.wmv
```