class ProcessWrapper
  HTTPCHECK_INTERVAL = 0.01

  attr_reader :pid

  def initialize(opts = {}, verbose = false)
    @verbose = verbose
  end


  def start
    raise "#{command} is already running" if running? || another_instance_is_running?
    @pid = spawn(command, *args, [:out, :err] => output)
  end


  def stop
    raise "#{command} is not running" unless running?
    Process.kill('TERM', @pid)
    Process.waitpid(@pid)
    @pid = nil
  end


  def destroy
    stop if running?
  end


  def running?
    !!@pid
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


  private
  def wait_for_http_port
    until http_port_open? do
      sleep HTTPCHECK_INTERVAL
    end
    puts "HTTP port #{http_port} responded to /ping." if @verbose
  end


  def wait_for_no_http_port
    until !http_port_open? do
      sleep HTTPCHECK_INTERVAL
    end
    puts "HTTP port #{http_port} stopped responding to /ping." if @verbose
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
