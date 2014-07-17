require 'helper'

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
    it 'ensures nsql cluster is fully running after its execution' do
      cluster = NsqCluster.new(nsqd_count: 1, nsqlookupd_count: 1)
      cluster.block_until_running
      cluster.send(:service_ports).keys.each do |port|
        # This will raise an exception if the service is not yet running.
        sock = TCPSocket.new('127.0.0.1', port)
        sock.close
      end
      cluster.destroy
    end
  end


  describe '#service_ports' do
    it 'includes TCP and HTTP ports for nsqd, nsqlookupd and nsqadmin' do
      cluster = NsqCluster.new({
        nsqd_count: 2,
        nsqlookupd_count: 2,
        nsqadmin: true,
        silent: true
      })
      # 2 HTTP nsqd, 2 TCP nsqd, 2 HTTP nsqlookup, 2 TCP nsqlookup, 1 nsqadmin
      (cluster.send :service_ports).keys.count.must_equal 9
      cluster.destroy
    end
    it 'works when nsqadmin not enabled' do
      cluster = NsqCluster.new({
        nsqd_count: 2,
        nsqlookupd_count: 2,
        nsqadmin: false,
        silent: true
      })
      # 2 HTTP nsqd, 2 TCP nsqd, 2 HTTP nsqlookup, 2 TCP nsqlookup
      (cluster.send :service_ports).keys.count.must_equal 8
      cluster.destroy
    end
  end
end
