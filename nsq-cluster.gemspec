# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'nsq-cluster'
  s.version = '1.1.1'

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ['Wistia']
  s.date = '2015-03-24'
  s.description = 'Setup nsqd, nsqlookupd, and nsqadmin in a jiffy. Great for testing!'
  s.email = 'dev@wistia.com'
  s.executables = ['nsq-cluster']
  s.extra_rdoc_files = %w( LICENSE README.md )
  s.files = `git ls-files`.split($/)
  s.homepage = 'http://github.com/wistia/nsq-cluster'
  s.licenses = ['MIT']
  s.require_paths = ['lib']
  s.rubygems_version = '2.0.3'
  s.summary = 'Easily setup and manage a local NSQ cluster'

  if ENV['PLATFORM'] == 'java' || ::RUBY_PLATFORM == 'java'
    s.platform = 'java'
  else
    s.add_dependency(%q<sys-proctable>, ['>= 0'])
  end

  s.add_development_dependency(%q<fakeweb>, ['~> 1.3'])
  s.add_development_dependency(%q<rspec>, ['~> 3.0'])
end

