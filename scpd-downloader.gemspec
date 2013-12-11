# encoding: UTF-8
Gem::Specification.new do |s|
  s.name        = 'scpd-downloader'
  s.version     = '0.1'
  s.summary     = 'Downloads lecture videos from Stanford SCPD'
  s.description = 'You need a valid Stanford SUNet ID. Supports two-step authentication. Videos are streamed, so downloading lectures may take a while.'
  s.authors     = ['dennybritz']
  s.homepage    = 'https://github.com/dennybritz/scpd-downloader'

  s.platform    = Gem::Platform::RUBY
  s.files       = `git ls-files`.split($RS)
  s.bindir      = 'bin/'
  s.executables = ['scpd-downloader']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'
  s.add_runtime_dependency('json', '>=1.8.1')
  s.add_runtime_dependency('mechanize', '>=2.7.3')
end
