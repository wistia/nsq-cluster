require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'nsq-cluster'

RSpec.configure do |config|
  config.color = true
  config.order = :random
  config.tty = true
end
