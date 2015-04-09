require_relative 'process_wrapper'

class Nsqadmin < ProcessWrapper

  attr_reader :host, :http_port

  def initialize(opts = {}, verbose = false)
    super

    @host      = self.class.host || '127.0.0.1'
    @http_port = opts.delete(:http_port) || self.class.base_port || 4171
    @lookupd   = opts.delete(:nsqlookupd) || []

    @extra_args = opts.map do |key, value|
      "--#{key.to_s.gsub('_', '-')}=#{value}"
    end
  end

  def command
    'nsqadmin'
  end

  def args
    base_args    = %W{ --http-address=#{@host}:#{@http_port} }
    lookupd_args = @lookupd.map { |ld| %Q(--lookupd-http-address=#{ld.host}:#{ld.http_port}) }

    base_args + @extra_args + lookupd_args
  end

  private

  def setup_process
    super
    @process.leader = true
  end

end

