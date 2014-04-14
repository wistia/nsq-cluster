class ProcessWrapper


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

end

