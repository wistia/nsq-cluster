require_relative '../spec_helper'

require 'socket'

describe NsqCluster do
  describe '#initialize' do
    it 'should start up a cluster' do
      cluster = NsqCluster.new(nsqd_count: 1, nsqlookupd_count: 1)
      expect(cluster.nsqd.length).to equal(1)
      expect(cluster.nsqlookupd.length).to equal(1)
      cluster.destroy
    end
  end


  describe '#block_until_running' do
    it 'ensures nsql cluster is running after execution' do
      cluster = NsqCluster.new(
        nsqd_count: 1, nsqlookupd_count: 1, nsqadmin: true
      )
      cluster.block_until_running
      cluster.send(:all_services).each do |service|
        expect(
          lambda {
            sock = TCPSocket.new(service.host, service.http_port)
            sock.close
          }
        ).not_to raise_error
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
        expect{
          sock = TCPSocket.new(service.host, service.http_port)
          sock.close
        }.not_to raise_error
      end
      cluster.destroy
      cluster.block_until_stopped
      services.each do |service|
        expect{
          sock = TCPSocket.new(service.host, service.http_port)
          sock.close
        }.to raise_error(Errno::ECONNREFUSED)
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
