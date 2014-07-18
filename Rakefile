# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "nsq-cluster"
  gem.homepage = "http://github.com/wistia/nsq-cluster"
  gem.license = "MIT"
  gem.summary = %Q{Easily setup and manage a local NSQ cluster}
  gem.description = %Q{Setup nsqd, nsqlookupd, and nsqadmin in a jiffy. Great for testing!}
  gem.email = "dev@wistia.com"
  gem.authors = ["Wistia"]
  gem.files = Dir.glob('lib/**/*.rb') + Dir.glob('bin/*') + ['LICENSE', 'README.md']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:spec) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'spec/**/*_spec.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "nsq-cluster #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
