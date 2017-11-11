class TaskController < ApplicationController
  def index
		begin
			if (File.exists?("/app/tmp/pids/delayed_job.pid")) 
				Process.kill(0,`cat /app/tmp/pids/delayed_job.pid`.to_i)
				@running = true
			else
				@running = false
			end
		rescue
			@running = false
		end
  end

  def run_now
  	job = Delayed::Job.find(params["id"])
    job.run_now(true)
  	redirect_to "/"
  end
end
