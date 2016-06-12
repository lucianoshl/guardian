
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    spawn("bin/delayed_job stop") 
    Process.kill 'QUIT', Process.pid
  end 

  $pid = spawn("bin/delayed_job -n 1 --log-dir=#{Rails.root}/log start ") 

end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end
end