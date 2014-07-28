require_relative '../spec_helper'

require 'socket'

describe NsqCluster do

  def expect_port_to_be_open(host, port)
    expect{
      sock = TCPSocket.new(host, port)
      sock.close
    }.not_to raise_error
  end

  def expect_port_to_be_closed(host, port)
    expect{
      sock = TCPSocket.new(host, port)
      sock.close
    }.to raise_error(Errno::ECONNREFUSED)
  end

  describe '#initialize' do
    it 'should start up a cluster' do
      cluster = NsqCluster.new(nsqd_count: 1, nsqlookupd_count: 1)
      expect(cluster.nsqd.length).to equal(1)
      expect(cluster.nsqlookupd.length).to equal(1)
      cluster.destroy
    end

    it 'should raise an exception if a component of the cluster is already started' do
      old_cluster = NsqCluster.new(nsqd_count: 1)
      old_cluster.block_until_running

      expect{
        new_cluster = NsqCluster.new(nsqd_count: 1, nsqlookupd_count: 1)
      }.to raise_error

      old_cluster.destroy
    end

    it 'should clean up any services it started if it errors out while starting' do
      old_cluster = NsqCluster.new(nsqd_count: 1)
      old_cluster.block_until_running

      begin
        NsqCluster.new(nsqd_count: 1, nsqlookupd_count: 1)
      rescue
        # ignore the error
      end

      lookupd = Nsqlookupd.new
      expect_port_to_be_closed(lookupd.host, lookupd.tcp_port)

      old_cluster.destroy
    end

    it 'should raise an exception if nsqd and friends aren\'t available' do
      allow_any_instance_of(Nsqd).to receive(:command).and_return('executable-that-does-not-exist')
      expect{
        NsqCluster.new(nsqd_count: 1).destroy
      }.to raise_error(Errno::ENOENT)
    end
  end


  describe '#block_until_running' do
    it 'ensures nsql cluster is running after execution' do
      cluster = NsqCluster.new(
        nsqd_count: 1, nsqlookupd_count: 1, nsqadmin: true
      )
      cluster.block_until_running
      cluster.send(:all_services).each do |service|
        expect_port_to_be_open(service.host, service.http_port)
      end
      cluster.destroy
    end
  end


  describe '#block_until_stopped' do
    it 'ensures nsql cluster is stopped after execution' do
      cluster = NsqCluster.new(
        nsqd_count: 3, nsqlookupd_count: 3, nsqadmin: true
      )
      cluster.block_until_running
      services = cluster.send(:all_services)
      services.each do |service|
        expect_port_to_be_open(service.host, service.http_port)
      end
      cluster.destroy
      cluster.block_until_stopped
      services.each do |service|
        expect_port_to_be_closed(service.host, service.http_port)
      end
    end
  end


  describe '#all_services' do
    it 'contains array with every instance of every service' do
      cluster = NsqCluster.new(
        nsqd_count: 3,
        nsqlookupd_count: 2,
        nsqadmin: true
      )
      all_services = cluster.send :all_services
      expect(all_services.count).to equal(6)
      expect(all_services.select{|m| m.is_a?(Nsqd)}.count).to equal(3)
      expect(all_services.select{|m| m.is_a?(Nsqlookupd)}.count).to equal(2)
      expect(all_services.select{|m| m.is_a?(Nsqadmin)}.count).to equal(1)
      cluster.destroy
    end
  end
end
