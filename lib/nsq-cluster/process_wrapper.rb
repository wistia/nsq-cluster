require 'childprocess'

class ProcessWrapper

  HTTPCHECK_INTERVAL = 0.01

  attr_reader :pid

  def initialize(opts = {}, verbose = false)
    @verbose = verbose
  end

  def start(opts = {})
    puts "[#{uid}] start : running : #{running?} : another_instance_is_running? :#{another_instance_is_running?}" if @verbose
    if running?
      puts "[#{uid}] start : already running, raising exception ..." if @verbose
      raise "#{uid} is already running"
    end
    if another_instance_is_running?
      puts "[#{uid}] start : already running on another process, raising exception ..." if @verbose
      raise "#{uid} is already running on another process"
    end
    puts "[#{uid}] start : setup_process"
    setup_process
    puts "[#{uid}] start : start_process"
    start_process
    puts "[#{uid}] start : block_until_running"
    block_until_running unless opts[:async]
    puts "[#{uid}] start : at_exit"
    at_exit { stop }
    puts "[#{uid}] start : done"
    true
  end

  def stop(opts = {})
    puts "[#{uid}] stop : running : #{running?}" if @verbose
    return false unless running?

    puts "[#{uid}] stop : running : #{running?} : full stop ..."
    @process.stop
    puts "[#{uid}] stop : running : #{running?} : blocking until stopped ..."
    block_until_stopped unless opts[:async]
  end

  def destroy
    puts "[#{uid}] destroy : running : #{running?}" if @verbose
    stop if running?
  end

  def running?
    puts "[#{uid}] running? : @process : #{@process.class.name} : #{@process ? @process.alive? : 'N/A'} " if @verbose
    @process && @process.alive?
  end

  def another_instance_is_running?
    if respond_to?(:http_port)
      http_port_open?
    else
      false
    end
  end

  def command
    raise 'you have to override this in a subclass, hotshot'
  end

  def args
    raise 'you have to override this in a subclass as well, buddy'
  end

  def output
    if @verbose
      :out
    else
      '/dev/null'
    end
  end

  def block_until_running
    if respond_to?(:http_port) && respond_to?(:host)
      wait_for_http_port
    else
      raise "Can't block without http port and host"
    end
  end

  def block_until_stopped
    if respond_to?(:http_port) && respond_to?(:host)
      wait_for_no_http_port
    else
      raise "Can't block without http port and host"
    end
  end

  def pid
    @process && @process.pid
  end

  def uid
    str = "#{command}"
    str << ":#{@id}" unless @id.nil?
    str << ":#{pid}" unless pid.nil?
    str
  end

  class << self
    attr_accessor :host, :base_port
  end

  def ports_info_str
    ''
  end

  def to_s
    "#<#{self.class.name} host=#{@host}#{ports_info_str}>"
  end

  alias :inspect :to_s

  private

  def setup_process
    @process        = ::ChildProcess.build command, *args.map { |x| x.to_s }
    @process.leader = true
    if @verbose
      @process.io.stdout = STDOUT
      @process.io.stderr = STDERR
    end
  end

  def start_process
    @process.start
    if @process.alive?
      puts "[#{uid}] start_process : is alive" if @verbose
    else
      puts "[#{uid}] start_process : is NOT alive" if @verbose
      raise "could not start #{uid} process"
    end
  end

  def wait_for_http_port
    until http_port_open? do
      sleep HTTPCHECK_INTERVAL
    end
    puts "[#{uid}] HTTP port #{http_port} responded to /ping." if @verbose
    true
  end

  def wait_for_no_http_port
    until !http_port_open? do
      sleep HTTPCHECK_INTERVAL
    end
    puts "[#{uid}] HTTP port #{http_port} stopped responding to /ping." if @verbose
    true
  end

  def http_port_open?
    begin
      response = Net::HTTP.get_response(URI("http://#{host}:#{http_port}/ping"))
      return response.is_a?(Net::HTTPSuccess)
    rescue Errno::ECONNREFUSED
      return false
    end
  end

end
