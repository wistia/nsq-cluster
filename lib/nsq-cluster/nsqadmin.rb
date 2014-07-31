require 'sys/proctable'

require_relative 'process_wrapper'

class Nsqadmin < ProcessWrapper

  attr_reader :host, :http_port

  def initialize(opts = {}, verbose = false)
    super

    @host = '127.0.0.1'
    @http_port = opts.delete(:http_port) || 4171
    @lookupd = opts.delete(:nsqlookupd) || []

    @extra_args = opts.map do |key, value|
      "--#{key.to_s.gsub('_', '-')}=#{value}"
    end
  end


  def stop(opts = {})
    Sys::ProcTable.ps.select{|pe| pe.ppid == @pid}.each do |child_pid|
      Process.kill('TERM', child_pid)
    end
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

    base_args + @extra_args + lookupd_args
  end

end

