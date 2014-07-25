#
# This provides an easy way to locally spin up a cluster of `nsqd` and
# `nsqlookupd` processes.
#
# Usage:
#
#     require 'nsq-cluster'
#     cluster = NsqCluster.new(nsqd_count: 2, nsqlookupd_count: 2)
#     cluster.nsqd[0].stop
#     cluster.nsqd[0].start
#     cluster.destroy
#

require 'net/http'
require 'timeout'

require_relative 'nsq-cluster/nsqlookupd'
require_relative 'nsq-cluster/nsqd'
require_relative 'nsq-cluster/nsqadmin'

class NsqCluster
  attr_reader :nsqd, :nsqlookupd, :nsqadmin

  def initialize(opts = {})
    opts = {
      nsqlookupd_count: 0,
      nsqdlookupd_options: {},
      nsqd_count: 0,
      nsqadmin: false,
      nsqd_options: {},
      silent: true
    }.merge(opts)
    @silent = opts[:silent]

    @nsqlookupd = create_nsqlookupds(opts[:nsqlookupd_count], opts[:nsqdlookupd_options])
    @nsqd = create_nsqds(opts[:nsqd_count], opts[:nsqd_options])
    @nsqadmin = create_nsqadmin if opts[:nsqadmin]

    # start everything!
    all_services.each { |d| d.start }
  end


  def create_nsqlookupds(count, options)
    (0...count).map do |idx|
      Nsqlookupd.new(options.merge({
        tcp_port: 4160 + idx * 2,
        http_port: 4161 + idx * 2,
        silent: @silent
      }))
    end
  end


  def create_nsqds(count, options)
    (0...count).map do |idx|
      Nsqd.new(options.merge({
        tcp_port: 4150 + idx * 2,
        http_port: 4151 + idx * 2,
        nsqlookupd: @nsqlookupd,
        silent: @silent
      }))
    end
  end


  def create_nsqadmin
    Nsqadmin.new(
      nsqlookupd: @nsqlookupd,
      silent: @silent
    )
  end


  def destroy
    all_services.each{|s| s.destroy}
  end


  # return an array of http endpoints
  def nsqlookupd_http_endpoints
    @nsqlookupd.map { |lookupd| "http://#{lookupd.host}:#{lookupd.http_port}" }
  end


  def block_until_running(timeout = 10)
    puts "Waiting for cluster to launch..." unless @silent
    begin
      Timeout::timeout(timeout) do
        all_services.each {|service| service.block_until_running}
        puts "Cluster launched." unless @silent
      end
    rescue Timeout::Error
      raise "Cluster did not fully launch within #{timeout} seconds."
    end
  end


  def block_until_stopped(timeout = 10)
    puts "Waiting for cluster to stop..." unless @silent
    begin
      Timeout::timeout(timeout) do
        all_services.each{|service| service.block_until_stopped}
        puts "Cluster stopped." unless @silent
      end
    rescue Timeout::Error
      raise "Cluster did not fully stop within #{timeout} seconds."
    end
  end


  private
  def all_services
    # nsqadmin responds to /ping as well, even though it is not documented.
    (@nsqlookupd + @nsqd + [@nsqadmin]).compact
  end
end
