require_relative 'process_wrapper'

class Nsqlookupd < ProcessWrapper

  attr_reader :host, :tcp_port, :http_port

  def initialize(opts = {})
    @host = '127.0.0.1'
    @tcp_port = opts[:tcp_port] || 4160
    @http_port = opts[:http_port] || 4161

    super
  end


  def command
    'nsqlookupd'
  end


  def args
    [
      %Q(--tcp-address=#{@host}:#{@tcp_port}),
      %Q(--http-address=#{@host}:#{@http_port})
    ]
  end

end
