require_relative 'process_wrapper'
require_relative 'http_wrapper'

class Nsqlookupd < ProcessWrapper
  include HTTPWrapper

  attr_reader :host, :tcp_port, :http_port, :base_port

  def initialize(opts = {}, verbose = false)
    super

    @id = opts.delete(:id) || 0
    @host = opts.delete(:host) || '127.0.0.1'

    # Use a non-standard nsqlookupd port by default so as to not conflict with
    # any local instances. This is helpful when running tests!
    @base_port = opts.delete(:base_port) || 4360

    @tcp_port = opts.delete(:tcp_port) || (@base_port + @id * 2)
    @http_port = opts.delete(:http_port) || (@base_port + 1 + @id * 2)
    @broadcast_address = opts.delete(:broadcast_address) || @host

    @extra_args = opts.map do |key, value|
      "--#{key.to_s.gsub('_', '-')}=#{value}"
    end
  end


  def command
    'nsqlookupd'
  end


  def args
    [
      %Q(--tcp-address=#{@host}:#{@tcp_port}),
      %Q(--http-address=#{@host}:#{@http_port}),
      %Q(--broadcast-address=#{@broadcast_address})
    ] + @extra_args
  end


 # return a list of producers for a topic
  def lookup(topic)
    get 'lookup', topic: topic
  end


  # return a list of all known topics
  def topics
    get 'topics'
  end


  # return a list of all known channels for a topic
  def channels(topic)
    get 'channels', topic: topic
  end


  # return a list of all known nsqd
  def nodes
    get 'nodes'
  end


  # delete a topic or a channel in an existing topic
  def delete(params = {})
    nsqlookupd_post 'delete', topic: params[:topic], channel: params[:channel]
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


  def nsqlookupd_post(action, params)
    if params[:topic] && params[:channel]
      post "channel/#{action}", topic: params[:topic], channel: params[:channel]
    elsif params[:topic]
      post "topic/#{action}", topic: params[:topic]
    else
      raise 'you must specify a topic or topic and channel'
    end
  end

end
