require_relative 'process_wrapper'
require 'fileutils'

class Nsqd < ProcessWrapper


  attr_reader :host, :tcp_port, :http_port


  def initialize(opts = {})
    @host = '127.0.0.1'
    @tcp_port = opts[:tcp_port] || 4150
    @http_port = opts[:http_port] || 4151
    @lookupd = opts[:nsqlookupd] || []
    @msg_timeout = opts[:msg_timeout] || '60s'

    clear_data_directory
    create_data_directory

    super
  end


  def destroy
    super
    clear_data_directory
  end


  def command
    'nsqd'
  end


  def args
    base_args = [
      %Q(--tcp-address=#{@host}:#{@tcp_port}),
      %Q(--http-address=#{@host}:#{@http_port}),
      %Q(--data-path=#{data_path}),
      %Q(--worker-id=#{worker_id}),
      %Q(--msg-timeout=#{@msg_timeout})
    ]

    lookupd_args = @lookupd.map do |ld|
      %Q(--lookupd-tcp-address=#{ld.host}:#{ld.tcp_port})
    end

    base_args + lookupd_args
  end


  def worker_id
    @tcp_port
  end


  # find or create a temporary data directory for this instance
  def data_path
    "/tmp/nsqd-#{worker_id}"
  end


  private

  def create_data_directory
    Dir.mkdir(data_path)
  end


  def clear_data_directory
    FileUtils.rm_rf(data_path) if Dir.exist?(data_path)
  end

end
