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
      verbose: false
    }.merge(opts)

    @verbose = opts[:verbose]
    @nsqlookupd = create_nsqlookupds(opts[:nsqlookupd_count], opts[:nsqdlookupd_options])
    @nsqd = create_nsqds(opts[:nsqd_count], opts[:nsqd_options])
    @nsqadmin = create_nsqadmin if opts[:nsqadmin]

    begin
      # start everything!
      all_services.each { |d| d.start }
    rescue Exception => ex
      # if we hit an error, stop everything that we started
      destroy
      raise ex
    end
  end


  def create_nsqlookupds(count, options)
    (0...count).map do |idx|
      Nsqlookupd.new(
        options.merge({
          id: idx
        }),
        @verbose
      )
    end
  end


  def create_nsqds(count, options)
    (0...count).map do |idx|
      Nsqd.new(
        options.merge({
          id: idx,
          nsqlookupd: @nsqlookupd
        }),
        @verbose
      )
    end
  end


  def create_nsqadmin
    Nsqadmin.new(
      { nsqlookupd: @nsqlookupd },
      @verbose
    )
  end


  def destroy
    all_services.each{|s| s.destroy}
  end


  # return an array of http endpoints
  def nsqlookupd_http_endpoints
    @nsqlookupd.map { |lookupd| "http://#{lookupd.host}:#{lookupd.http_port}" }
  end


  def block_until_running(timeout = 3)
    puts "Waiting for cluster to launch..." if @verbose
    begin
      Timeout::timeout(timeout) do
        all_services.each {|service| service.block_until_running}
        puts "Cluster launched." if @verbose
      end
    rescue Timeout::Error
      raise "Cluster did not fully launch within #{timeout} seconds."
    end
  end


  def block_until_stopped(timeout = 10)
    puts "Waiting for cluster to stop..." if @verbose
    begin
      Timeout::timeout(timeout) do
        all_services.each{|service| service.block_until_stopped}
        puts "Cluster stopped." if @verbose
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
