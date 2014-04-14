require_relative 'process_wrapper'

class Nsqadmin < ProcessWrapper

  attr_reader :host, :http_port

  def initialize(opts = {})
    @host = '127.0.0.1'
    @http_port = opts[:http_port] || 4171
    @lookupd = opts[:nsqlookupd] || []

    super
  end


  def command
    'nsqadmin'
  end


  def args
    base_args = [
      %Q(--http-address=#{@host}:#{@http_port})
    ]

    lookupd_args = @lookupd.map do |ld|
      %Q(--lookupd-http-address=#{ld.host}:#{ld.http_port})
    end

    base_args + lookupd_args
  end

end

