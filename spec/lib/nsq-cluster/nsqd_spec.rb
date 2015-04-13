require_relative '../../spec_helper'

require 'json'

describe Nsqd do

  describe '::new' do
    it 'should use a non-standard base port' do
      nsqd = Nsqd.new
      expect(nsqd.base_port).to_not eq(4150)
    end

    it 'should have tcp_port and http_port set by default' do
      nsqd = Nsqd.new
      expect(nsqd.tcp_port).to eq(nsqd.base_port)
      expect(nsqd.http_port).to eq(nsqd.base_port + 1)
    end

    it 'should set tcp_port and http_port based on id if they\'re not specified' do
      id   = 5
      nsqd = Nsqd.new(id: id)
      expect(nsqd.tcp_port).to eq(nsqd.base_port + id * 2)
      expect(nsqd.http_port).to eq(nsqd.base_port + 1 + id * 2)
    end
  end

  describe '#args' do
    it 'includes arbitrary options passed in to the constructor' do
      nsqd = Nsqd.new(some_random_flag: '60s')
      arg  = '--some-random-flag=60s'
      expect(nsqd.args.include?(arg)).to eq(true)
    end
  end

  describe 'while running' do

    before do
      @cluster = NsqCluster.new(nsqd_count: 1, nsqlookupd_count: 1)
      @nsqd    = @cluster.nsqd.first
      @nsqd.block_until_running
    end

    after do
      @cluster.destroy
    end

    describe 'api endpoints' do
      describe '#ping' do
        it 'should return status 200' do
          expect(@nsqd.ping.code).to eql('200')
        end
      end

      describe '#info' do
        it 'should return status 200' do
          expect(@nsqd.info.code).to eql('200')
        end
      end

      describe '#stats' do
        it 'should return status 200' do
          expect(@nsqd.stats.code).to eql('200')
        end

        it 'should return JSON' do
          expect(JSON.parse(@nsqd.stats.body).is_a?(Hash)).to equal(true)
        end
      end

      describe '#pub' do
        it 'should return status 200' do
          resp = @nsqd.pub('test', 'a message')
          expect(resp.code).to eql('200')
        end
      end

      describe '#mpub' do
        it 'should return status 200' do
          resp = @nsqd.mpub('test', 'a message', 'another message', 'last message')
          expect(resp.code).to eql('200')
        end

        it 'should create multiple messages' do
          @nsqd.mpub('test', 'a message', 'another message', 'last message')

          topic = JSON.parse(@nsqd.stats.body)['data']['topics'].select do |t|
            t['topic_name'] == 'test'
          end.first

          expect(topic['message_count']).to equal(3)
        end
      end

      describe '#create' do
        it 'should return status 200' do
          resp1 = @nsqd.create(topic: 'test')
          resp2 = @nsqd.create(topic: 'test', channel: 'default')
          expect(resp1.code).to eql('200')
          expect(resp2.code).to eql('200')
        end

        it 'should raise error if topic is not specified' do
          expect(
            proc { @nsqd.create(channel: 'default') }
          ).to raise_error(RuntimeError)
        end
      end

      describe '#delete' do
        before do
          @nsqd.create(topic: 'test')
        end

        describe 'an existing channel' do
          it 'should return status 200' do
            @nsqd.create(topic: 'test', channel: 'default')
            resp = @nsqd.delete(topic: 'test', channel: 'default')
            expect(resp.code).to eql('200')
          end
        end

        describe 'a non-existant channel' do
          it 'should return status 500' do
            resp = @nsqd.delete(topic: 'test', channel: 'default')
            expect(resp.code).to eql('500')
          end
        end
      end

      describe '#pause' do
        before do
          @nsqd.create(topic: 'test')
        end

        describe 'an existing channel' do
          it 'should return status 200' do
            @nsqd.create(topic: 'test', channel: 'default')
            resp = @nsqd.pause(topic: 'test', channel: 'default')
            expect(resp.code).to eql('200')
          end
        end

        describe 'a non-existant channel' do
          it 'should return status 500' do
            resp = @nsqd.pause(topic: 'test', channel: 'default')
            expect(resp.code).to eql('500')
          end
        end
      end

      describe '#unpause' do
        before do
          @nsqd.create(topic: 'test')
        end

        describe 'an existing channel' do
          it 'should return status 200' do
            @nsqd.create(topic: 'test', channel: 'default')
            resp = @nsqd.unpause(topic: 'test', channel: 'default')
            expect(resp.code).to eql('200')
          end
        end

        describe 'a non-existant channel' do
          it 'should return status 500' do
            resp = @nsqd.unpause(topic: 'test', channel: 'default')
            expect(resp.code).to eql('500')
          end
        end
      end

      describe '#empty' do
        before do
          @nsqd.create(topic: 'test')
        end

        describe 'an existing channel' do
          it 'should return status 200' do
            @nsqd.create(topic: 'test', channel: 'default')
            resp = @nsqd.empty(topic: 'test', channel: 'default')
            expect(resp.code).to eql('200')
          end
        end

        describe 'a non-existant channel' do
          it 'should return status 500' do
            resp = @nsqd.empty(topic: 'test', channel: 'default')
            expect(resp.code).to eql('500')
          end
        end
      end
    end
  end
end
