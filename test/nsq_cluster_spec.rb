require 'helper'

require 'socket'

describe NsqCluster do
  describe '#initialize' do
    it 'should start up a cluster for realsies' do
      cluster = NsqCluster.new(nsqd_count: 1, nsqlookupd_count: 1)
      cluster.nsqd.length.must_equal 1
      cluster.nsqlookupd.length.must_equal 1
      cluster.destroy
    end
  end


  describe '#block_until_running' do
    it 'ensures nsql cluster is running after execution' do
      cluster = NsqCluster.new(nsqd_count: 1, nsqlookupd_count: 1)
      cluster.block_until_running
      cluster.send(:all_services).each do |service|
        # This will raise an exception if the service is not yet running.
        sock = TCPSocket.new(service.host, service.http_port)
        sock.close
      end
      cluster.destroy
    end

    it 'supports nsqadmin' do
      cluster = NsqCluster.new(
        nsqd_count: 1,
        nsqlookupd_count: 1,
        nsqadmin: true
      )
      cluster.block_until_running
      cluster.send(:all_services).each do |service|
        # This will raise an exception if the service is not yet running.
        sock = TCPSocket.new(service.host, service.http_port)
        sock.close
      end
      cluster.destroy
    end
  end


  describe '#all_services' do
    it 'contains array with every instance of every service' do
      # cluster = NsqCluster.new(
      #   nsqd_count: 3,
      #   nsqlookupd_count: 2,
      #   nsqadmin: true
      # )
      # all_services = cluster.send :all_services
      # expect(all_services.count).to equal(6)
      # expect(all_services.map{|m| m.is_a?(Nsqd)}.count).to equal(3)
      # expect(all_services.map{|m| m.is_a?(Nsqlookupd)}.count).to equal(2)
      # expect(all_services.map{|m| m.is_a?(Nsqadmin)}.count).to equal(1)
    end
  end
end
