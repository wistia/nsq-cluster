require_relative 'process_wrapper'
require_relative 'http_wrapper'

class Nsqlookupd < ProcessWrapper
  include HTTPWrapper

  attr_reader :host, :tcp_port, :http_port, :base_port

  def initialize(opts = {}, verbose = false)
    super

    @id        = opts.delete(:id) || 0
    @host      = opts.delete(:host) || self.class.host || '127.0.0.1'

    # You can configure the port at the class or instance level to avoid clashing with any local instance
    @base_port = opts.delete(:base_port) || self.class.base_port || 4160

    @tcp_port          = opts.delete(:tcp_port) || (@base_port + @id * 2)
    @http_port         = opts.delete(:http_port) || (@base_port + 1 + @id * 2)
    @broadcast_address = opts.delete(:broadcast_address) || @host

    @extra_args = opts.map do |key, value|
      "--#{key.to_s.gsub('_', '-')}=#{value}"
    end
  end

  def command
    'nsqlookupd'
  end

  def args
    %W{
      --tcp-address=#{@host}:#{@tcp_port}
      --http-address=#{@host}:#{@http_port}
      --broadcast-address=#{@broadcast_address}
    } + @extra_args
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
      post "#{action}_channel", topic: params[:topic], channel: params[:channel]
    elsif params[:topic]
      post "#{action}_topic", topic: params[:topic]
    else
      raise 'you must specify a topic or topic and channel'
    end
  end

end
