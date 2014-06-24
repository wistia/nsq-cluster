require_relative 'process_wrapper'
require_relative 'http_wrapper'

class Nsqlookupd < ProcessWrapper
  include HTTPWrapper

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
