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
    it 'does nothing if host not defined' do
      ProcessWrapper.send :remove_method, :host
      pw = ProcessWrapper.new
      expect(pw).not_to receive(:wait_for_http_port)
      pw.block_until_running
    end
    it 'does nothing if http_port not defined' do
      ProcessWrapper.send :remove_method, :http_port
      pw = ProcessWrapper.new
      expect(pw).not_to receive(:wait_for_http_port)
      pw.block_until_running
    end
  end
end
