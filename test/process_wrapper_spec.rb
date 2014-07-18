require 'helper'

describe ProcessWrapper do
  describe '#block_until_running' do
    it 'delegates to #wait_for_http_port when host and port are defined' do
      # pw = ProcessWrapper.new
      # pw.send :attr_reader, :http_port
      # pw.send :attr_reader, :host
      # expect(pw).to receive(:wait_for_http_port)
      # pw.block_until_running
    end
  end
end
