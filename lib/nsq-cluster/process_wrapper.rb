class ProcessWrapper
  HTTPCHECK_INTERVAL = 0.01


  def initialize(opts = {})
    @silent = opts[:silent]
  end


  def start
    raise "#{command} is already running" if running?
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


  def command
    raise 'you have to override this in a subclass, hotshot'
  end


  def args
    raise 'you have to override this in a subclass as well, buddy'
  end


  def output
    if @silent
      '/dev/null'
    else
      :out
    end
  end


  def block_until_running
    if respond_to?(:http_port) && respond_to?(:host)
      wait_for_http_port(http_port, host)
    else
      raise "Can't block without http port and host"
    end
  end


  def block_until_stopped
    if respond_to?(:http_port) && respond_to?(:host)
      wait_for_no_http_port(http_port, host)
    else
      raise "Can't block without http port and host"
    end
  end


  private
  def wait_for_http_port(port, host)
    port_open = false
    until port_open do
      begin
        response = Net::HTTP.get_response(URI("http://#{host}:#{port}/ping"))
        if response.is_a?(Net::HTTPSuccess)
          port_open = true
          puts "HTTP port #{port} responded to /ping." unless @silent
        else
          sleep HTTPCHECK_INTERVAL
        end
      rescue Errno::ECONNREFUSED
        sleep HTTPCHECK_INTERVAL
      end
    end
  end


  def wait_for_no_http_port(port, host)
    port_closed = false
    until port_closed do
      begin
        Net::HTTP.get_response(URI("http://#{host}:#{port}/ping"))
        sleep HTTPCHECK_INTERVAL
      rescue Errno::ECONNREFUSED
        puts "HTTP port #{port} stopped responding to /ping." unless @silent
        port_closed = true
      end
    end
  end
end
