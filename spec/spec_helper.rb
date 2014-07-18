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

require 'fakeweb'

RSpec.configure do |config|
  config.color = true
  config.order = :random
  config.tty = true
end

RSpec.configuration.before :each do
  FakeWeb.allow_net_connect = %r[^https?://#{Regexp.escape('127.0.0.1')}.*]
end
