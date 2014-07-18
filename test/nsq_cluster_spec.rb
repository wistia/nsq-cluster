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
      cluster.send(:running_http_services).each do |port, host|
        # This will raise an exception if the service is not yet running.
        sock = TCPSocket.new(host, port)
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
      cluster.send(:running_http_services).each do |port, host|
        # This will raise an exception if the service is not yet running.
        sock = TCPSocket.new(host, port)
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
      # 2 HTTP nsqd, 2 HTTP nsqlookup, 1 HTTP nsqadmin
      (cluster.send :running_http_services).keys.count.must_equal 5
      cluster.destroy
    end
    it 'works when nsqadmin not enabled' do
      cluster = NsqCluster.new({
        nsqd_count: 2,
        nsqlookupd_count: 2,
        nsqadmin: false,
        silent: true
      })
      # 2 HTTP nsqd, 2 HTTP nsqlookup
      (cluster.send :running_http_services).keys.count.must_equal 4
      cluster.destroy
    end
  end
end
