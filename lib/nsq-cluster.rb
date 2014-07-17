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

require 'socket'
require 'timeout'

require_relative 'nsq-cluster/nsqlookupd'
require_relative 'nsq-cluster/nsqd'
require_relative 'nsq-cluster/nsqadmin'

class NsqCluster
  PORTSCAN_INTERVAL = 0.01
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
    (@nsqlookupd + @nsqd + [@nsqadmin]).compact.each { |d| d.start }
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
    (@nsqd + @nsqlookupd).each { |d| d.destroy }
  end


  # return an array of http endpoints
  def nsqlookupd_http_endpoints
    @nsqlookupd.map { |lookupd| "http://#{lookupd.host}:#{lookupd.http_port}" }
  end


  def block_until_running(timeout = 3)
    puts "Waiting for cluster to launch..." unless @silent
    begin
      Timeout::timeout(timeout) do
        service_ports.each do |port, protocol|
          wait_for_port(port, protocol)
        end
        puts "Cluster launched." unless @silent
      end
    rescue Timeout::Error
      puts "ERROR: Cluster did not fully launch within #{timeout} seconds."
    end
  end


  private
  def service_ports
    ports = {}
    ports[nsqadmin.http_port] = :http if nsqadmin
    nsqlookupd.each do |n|
      ports[n.tcp_port] = :tcp
      ports[n.http_port] = :http
    end
    nsqd.each do |n|
      ports[n.tcp_port] = :tcp
      ports[n.http_port] = :http
    end
    ports
  end


  def wait_for_port(port, protocol)
    port_open = false
    until port_open do
      begin
        sock = TCPSocket.new('127.0.0.1', port)
        port_open = true
        puts "#{protocol.to_s.upcase} port #{port} open." unless @silent
        if protocol == :tcp
          puts "You may safely ignore: 'ERROR: failed to read protocol version - EOF'" unless @silent
        end
        sock.close
      rescue Errno::ECONNREFUSED
      end
      sleep PORTSCAN_INTERVAL if !port_open
    end
  end
end
