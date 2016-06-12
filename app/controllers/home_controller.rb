class HomeController < ApplicationController
	def index
		begin
			if (File.exists?("/app/tmp/pids/delayed_job.pid")) 
				Process.kill(0,`cat /app/tmp/pids/delayed_job.pid`.to_i)
			else
				@running = false
			end
		rescue
			@running = false
		end
	end
end
