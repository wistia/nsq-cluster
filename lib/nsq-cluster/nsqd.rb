require_relative 'process_wrapper'
require_relative 'http_wrapper'
require 'fileutils'

class Nsqd < ProcessWrapper
  include HTTPWrapper


  attr_reader :host, :tcp_port, :http_port


  def initialize(opts = {})
    @host = opts[:host] || '127.0.0.1'
    @tcp_port = opts[:tcp_port] || 4150
    @http_port = opts[:http_port] || 4151
    @lookupd = opts[:nsqlookupd] || []
    @msg_timeout = opts[:msg_timeout] || '60s'
    @broadcast_address = opts[:broadcast_address] || @host

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
      %Q(--msg-timeout=#{@msg_timeout}),
      %Q(--broadcast-address=#{@broadcast_address})
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
      post "#{action}_channel", topic: params[:topic], channel: params[:channel]
    elsif params[:topic]
      post "#{action}_topic", topic: params[:topic]
    else
      raise 'you must specify a topic or topic and channel'
    end
  end

end
