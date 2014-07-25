require_relative 'process_wrapper'

class Nsqadmin < ProcessWrapper

  attr_reader :host, :http_port

  def initialize(opts = {})
    @host = '127.0.0.1'
    @http_port = opts[:http_port] || 4171
    @lookupd = opts[:nsqlookupd] || []

    super
  end


  def stop
    super
    str = "ps | grep nsqadmin | "
    str += %Q{grep "\\-\\-http\\-address=#{Regexp.escape(host.to_s)}:#{Regexp.escape(http_port.to_s)}" | }
    @lookupd.each do |lookupd|
      str += %Q{grep "\\-\\-lookupd\\-http\\-address=#{Regexp.escape(lookupd.host)}:#{lookupd.http_port}" | }
    end
    str += "grep -v grep"
    pid = `#{str}`.split(/\s+/)[0]
    Process.kill('TERM', pid) if pid.to_i > 0
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

