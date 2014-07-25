require_relative '../../spec_helper'

describe ProcessWrapper do
  describe '#block_until_running' do
    before do
      ProcessWrapper.send :attr_reader, :http_port
      ProcessWrapper.send :attr_reader, :host
    end
    it 'delegates to #wait_for_http_port when host and port are defined' do
      pw = ProcessWrapper.new
      expect(pw).to receive(:wait_for_http_port)
      pw.block_until_running
    end
    it 'raises error if host is not defined' do
      described_class.send :remove_method, :host
      expect{described_class.new.block_until_running}.to raise_error
    end
    it 'raises error if http_port is not defined' do
      described_class.send :remove_method, :http_port
      expect{described_class.new.block_until_running}.to raise_error
    end
  end


  describe '#block_until_stopped' do
    before do
      ProcessWrapper.send :attr_reader, :http_port
      ProcessWrapper.send :attr_reader, :host
    end
    it 'delegates to #wait_for_no_http_port when host and port are defined' do
      described_class.send(:define_method, :http_port){8080}
      described_class.send(:define_method, :host){'localhost'}
      pw = described_class.new
      expect(pw).to receive(:wait_for_no_http_port)
      pw.block_until_stopped
    end
    it 'raises error if host is not defined' do
      described_class.send :remove_method, :host
      expect {described_class.new.block_until_stopped}.to raise_error
    end
    it 'raises error if http_port is not defined' do
      described_class.send :remove_method, :http_port
      expect{described_class.new.block_until_stopped}.to raise_error
    end
  end
end
