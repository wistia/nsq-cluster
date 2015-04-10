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
require 'lifeguard'
require 'thread_safe'

require_relative 'nsq-cluster/nsqlookupd'
require_relative 'nsq-cluster/nsqd'
require_relative 'nsq-cluster/nsqadmin'

class NsqCluster

  attr_reader :nsqd, :nsqlookupd, :nsqadmin

  def initialize(opts = {})
    opts = {
      nsqlookupd_count:    0,
      nsqdlookupd_options: {},
      nsqd_count:          0,
      nsqadmin:            false,
      nsqd_options:        {},
      verbose:             ENV.fetch('VERBOSE', 'false') == 'true'
    }.merge(opts)

    @verbose = opts[:verbose]

    pool_size = opts[:nsqlookupd_count] + opts[:nsqd_count] + (opts[:nsqadmin] ? 1 : 0)
    @pool     = ::Lifeguard::InfiniteThreadpool.new pool_size: pool_size

    @nsqlookupd = create_nsqlookupds(opts[:nsqlookupd_count], opts[:nsqdlookupd_options])
    @nsqd       = create_nsqds(opts[:nsqd_count], opts[:nsqd_options])
    @nsqadmin   = create_nsqadmin if opts[:nsqadmin]

    start_services(opts)
  end

  def create_nsqlookupds(count, options)
    (0...count).map do |idx|
      Nsqlookupd.new options.merge({ id: idx }), @verbose
    end
  end

  def create_nsqds(count, options)
    (0...count).map do |idx|
      Nsqd.new options.merge({ id: idx, nsqlookupd: @nsqlookupd }), @verbose
    end
  end

  def create_nsqadmin
    Nsqadmin.new({ nsqlookupd: @nsqlookupd }, @verbose)
  end

  def destroy
    run_cmd_in_all_services :destroy, 5
  end

  # return an array of http endpoints
  def nsqlookupd_http_endpoints
    @nsqlookupd.map { |lookupd| "http://#{lookupd.host}:#{lookupd.http_port}" }
  end

  def block_until_running(timeout = 3)
    puts 'Waiting for cluster to launch...' if @verbose
    begin
      Timeout::timeout(timeout) do
        run_cmd_in_all_services :block_until_running
        puts 'Cluster launched.' if @verbose
      end
    rescue Timeout::Error
      raise "Cluster did not fully launch within #{timeout} seconds."
    end
  end

  def services_statuses
    all_services.each_with_object({}) { |svc, hsh| hsh[svc.uid] = svc.running? }
  end

  def running?
    sts = services_statuses
    puts "statuses : #{sts.inspect}" if @verbose
    sts.values.all?
  end

  def block_until_stopped(timeout = 10)
    puts 'Waiting for cluster to stop...' if @verbose
    begin
      Timeout::timeout(timeout) do
        run_cmd_in_all_services :block_until_stopped
        puts 'Cluster stopped.' if @verbose
      end
    rescue Timeout::Error
      raise "Cluster did not fully stop within #{timeout} seconds."
    end
  end

  def to_s
    "#<#{self.class.name} nsqd=#{@nsqd.size} nsqlookupd=#{@nsqlookupd.size} nsqadmin=#{!!@nsqadmin} verbose=#{@verbose}>"
  end

  alias :inspect :to_s

  private

  def start_services(opts)
    begin
      puts 'starting everything' if @verbose
      run_cmd_in_all_services :start
      puts 'running everything?' if @verbose
      # raise 'Some services failed to stay running' unless running?
      running?

      puts 'block until running everything?' if @verbose
      # by default, block execution until everything is started
      block_until_running unless opts[:async]
    rescue Exception => ex
      # if we hit an error, stop everything that we started
      puts "start_services : #{ex.class.name} : #{ex.message}\n  #{ex.backtrace[0,5].join("\n  ")}" if @verbose
      destroy
      raise ex
    end
  end

  def all_services
    # nsqadmin responds to /ping as well, even though it is not documented.
    (@nsqlookupd + @nsqd + [@nsqadmin]).compact
  end

  # Run command in a thread per service and block until all have finished processing
  def run_cmd_in_all_services(meth, timeout = 3)
    puts "run_cmd_in_all_services : #{meth} : #{@pool.busy_size} : starting ..." if @verbose

    begin
      Timeout::timeout(timeout) do
        all_services.map { |service| service.send(meth) }
      end
    rescue Timeout::Error
      raise "Cluster did not #{meth} within #{timeout} seconds."
    end
  end
end
