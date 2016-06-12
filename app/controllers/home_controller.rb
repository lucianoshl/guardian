class HomeController < ApplicationController
	def index
		begin
			Process.kill(0,`cat /app/tmp/pids/delayed_job.pid`.to_i)
			@running = true
		rescue
			@running = false
		end
	end
end
