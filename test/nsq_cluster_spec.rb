require 'helper'

describe NsqCluster do

  it 'should start up a cluster for realsies' do
    cluster = NsqCluster.new(nsqd_count: 1, nsqlookupd_count: 1)
    cluster.nsqd.length.must_equal 1
    cluster.nsqlookupd.length.must_equal 1
    cluster.destroy
  end

end
