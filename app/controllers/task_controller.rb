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
  	job.run_at = Time.zone.now
  	job.attempts = 0
    job.locked_at = nil
    job.locked_by = nil
    job.last_error = nil
  	job.save
  	redirect_to action: "index"
  end
end
