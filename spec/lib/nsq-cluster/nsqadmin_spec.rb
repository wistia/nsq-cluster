require_relative '../../spec_helper'

describe Nsqadmin do

  describe '#args' do
    it 'includes arbitrary options passed in to the constructor' do
      nsqd = Nsqadmin.new(some_random_flag: '60s')
      arg = '--some-random-flag=60s'
      expect(nsqd.args.include?(arg)).to eq(true)
    end
  end

  describe '#stop' do
    it 'raises a exception because sys-proctable is missing' do
      nsqa = Nsqadmin.new
      expect { nsqa.stop }.to raise_error 'sys/proctable is not available to stop Nsqadmin ...'
    end
  end

end
