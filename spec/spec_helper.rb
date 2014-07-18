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

require 'rspec'
require 'fakeweb'
FakeWeb.allow_net_connect = false
FakeWeb.allow_net_connect = %r[^https?://#{Regexp.escape('127.0.0.1')}.*]

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

