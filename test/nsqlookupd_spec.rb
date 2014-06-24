require 'helper'

describe Nsqlookupd do

  before do
    @cluster = NsqCluster.new(nsqd_count: 1, nsqlookupd_count: 1)
    @nsqd = @cluster.nsqd.first
    @nsqlookupd = @cluster.nsqlookupd.first
    sleep 0.1
  end

  after do
    @cluster.destroy
  end

  describe 'api endpoints' do
    describe '#ping' do
      it 'should return status 200' do
        @nsqlookupd.ping.code.must_equal '200'
      end
    end

    describe '#info' do
      it 'should return status 200' do
        @nsqlookupd.info.code.must_equal '200'
      end
    end

    describe '#nodes' do
      it 'should return status 200' do
        @nsqlookupd.nodes.code.must_equal '200'
      end
    end

    describe '#topic' do
      it 'should return status 200' do
        @nsqlookupd.topics.code.must_equal '200'
      end
    end

    describe '#channels' do
      it 'should return status 200' do
        @nsqlookupd.channels('default').code.must_equal '200'
      end
    end

    describe '#lookup' do
      context 'an existing topic' do
        before do
          @nsqd.create(topic: 'test')
        end

        it 'should return status 200' do
          @nsqlookupd.lookup('test').code.must_equal '200'
        end
      end

      context 'a non-existant topic' do
        it 'should return status 500' do
          @nsqlookupd.lookup('wtf').code.must_equal '500'
        end
      end
    end
  end
end
