require 'helper'

describe Nsqd do

  before do
    @cluster = NsqCluster.new(nsqd_count: 1, nsqlookupd_count: 1)
    @nsqd = @cluster.nsqd.first
    sleep 0.1
  end

  after do
    @cluster.destroy
  end

  describe 'api endpoints' do
    describe '#ping' do
      it 'should return status 200' do
        @nsqd.ping.code.must_equal '200'
      end
    end

    describe '#info' do
      it 'should return status 200' do
        @nsqd.info.code.must_equal '200'
      end
    end

    describe '#stats' do
      it 'should return status 200' do
        @nsqd.stats.code.must_equal '200'
      end

      it 'should return JSON' do
        JSON.parse(@nsqd.stats.body).must_be_kind_of Hash
      end
    end

    describe '#create' do
      it 'should return status 200' do
        resp1 = @nsqd.create(topic: 'test')
        resp2 = @nsqd.create(topic: 'test', channel: 'default')
        resp1.code.must_equal '200'
        resp2.code.must_equal '200'
      end

      it 'should raise error if topic is not specified' do
        proc { @nsqd.create(channel: 'default') }.must_raise RuntimeError
      end
    end

    describe '#delete' do
      before do
        @nsqd.create(topic: 'test')
      end

      context 'an existing channel' do
        it 'should return status 200' do
          @nsqd.create(topic: 'test', channel: 'default')
          resp = @nsqd.delete(topic: 'test', channel: 'default')
          resp.code.must_equal '200'
        end
      end

      context 'a non-existant channel' do
        it 'should return status 500' do
          resp = @nsqd.delete(topic: 'test', channel: 'default')
          resp.code.must_equal '500'
        end
      end
    end

    describe '#pause' do
      before do
        @nsqd.create(topic: 'test')
      end

      context 'an existing channel' do
        it 'should return status 200' do
          @nsqd.create(topic: 'test', channel: 'default')
          resp = @nsqd.pause(topic: 'test', channel: 'default')
          resp.code.must_equal '200'
        end
      end

      context 'a non-existant channel' do
        it 'should return status 500' do
          resp = @nsqd.pause(topic: 'test', channel: 'default')
          resp.code.must_equal '500'
        end
      end
    end

    describe '#unpause' do
      before do
        @nsqd.create(topic: 'test')
      end

      context 'an existing channel' do
        it 'should return status 200' do
          @nsqd.create(topic: 'test', channel: 'default')
          resp = @nsqd.unpause(topic: 'test', channel: 'default')
          resp.code.must_equal '200'
        end
      end

      context 'a non-existant channel' do
        it 'should return status 500' do
          resp = @nsqd.unpause(topic: 'test', channel: 'default')
          resp.code.must_equal '500'
        end
      end
    end

    describe '#empty' do
      before do
        @nsqd.create(topic: 'test')
      end

      context 'an existing channel' do
        it 'should return status 200' do
          @nsqd.create(topic: 'test', channel: 'default')
          resp = @nsqd.empty(topic: 'test', channel: 'default')
          resp.code.must_equal '200'
        end
      end

      context 'a non-existant channel' do
        it 'should return status 500' do
          resp = @nsqd.empty(topic: 'test', channel: 'default')
          resp.code.must_equal '500'
        end
      end
    end
  end
end
