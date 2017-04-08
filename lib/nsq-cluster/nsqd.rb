require_relative 'process_wrapper'
require_relative 'http_wrapper'
require 'fileutils'

class Nsqd < ProcessWrapper
  include HTTPWrapper


  attr_reader :host, :tcp_port, :http_port, :id, :base_port

  # Returns true if nsqd's version is < 1.0
  def self.version_is_pre_1?
    @version_is_pre_1 ||= (
      `nsqd -version`.index('nsqd v0') == 0
    )
  end


  def initialize(opts = {}, verbose = false)
    super

    @id = opts.delete(:id) || 0
    @host = opts.delete(:host) || '127.0.0.1'

    # Use a non-standard nsqd port by default so as to not conflict with any
    # local instances. This is helpful when running tests!
    @base_port = opts.delete(:base_port) || 4250

    @tcp_port = opts.delete(:tcp_port) || (@base_port + @id * 2)
    @http_port = opts.delete(:http_port) || (@base_port + 1 + @id * 2)
    @lookupd = opts.delete(:nsqlookupd) || []
    @broadcast_address = opts.delete(:broadcast_address) || @host

    @extra_args = opts.map do |key, value|
      "--#{key.to_s.gsub('_', '-')}=#{value}"
    end

    clear_data_directory
    create_data_directory
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
      %Q(--broadcast-address=#{@broadcast_address})
    ]

    if Nsqd.version_is_pre_1?
      node_args = [%Q(--worker-id=#{id})]
    else
      node_args = [%Q(--node-id=#{id})]
    end

    lookupd_args = @lookupd.map do |ld|
      %Q(--lookupd-tcp-address=#{ld.host}:#{ld.tcp_port})
    end

    base_args + node_args + @extra_args + lookupd_args
  end


  # find or create a temporary data directory for this instance
  def data_path
    "/tmp/nsqd-#{id}"
  end


  # publish a single message to a topic
  def pub(topic, message)
    post 'pub', { topic: topic }, message
  end


  # publish multiple messages to a topic
  def mpub(topic, *messages)
    post 'mpub', { topic: topic }, messages.join("\n")
  end


  # create a topic or a channel in an existing topic
  def create(params = {})
    nsqd_post 'create', topic: params[:topic], channel: params[:channel]
  end


  # delete a topic or a channel in an existing topic
  def delete(params = {})
    nsqd_post 'delete', topic: params[:topic], channel: params[:channel]
  end


  # empty a topic or a channel in an existing topic
  def empty(params = {})
    nsqd_post 'empty', topic: params[:topic], channel: params[:channel]
  end


  # pause a topic or a channel in a topic
  def pause(params = {})
    nsqd_post 'pause', topic: params[:topic], channel: params[:channel]
  end


  # unpause a topic or a channel in a topic
  def unpause(params = {})
    nsqd_post 'unpause', topic: params[:topic], channel: params[:channel]
  end


  # return stats in json format
  def stats
    get 'stats', format: 'json'
  end


  # monitoring endpoint
  def ping
    get 'ping'
  end


  # returns version number
  def info
    get 'info'
  end


  private


  def create_data_directory
    Dir.mkdir(data_path)
  end


  def clear_data_directory
    FileUtils.rm_rf(data_path) if Dir.exist?(data_path)
  end


  def nsqd_post(action, params)
    if params[:topic] && params[:channel]
      post "channel/#{action}", topic: params[:topic], channel: params[:channel]
    elsif params[:topic]
      post "topic/#{action}", topic: params[:topic]
    else
      raise 'you must specify a topic or topic and channel'
    end
  end

end
