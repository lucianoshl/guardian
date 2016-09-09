class Mobile::LoggedClient

	def get uri,parameters = {}
	end

	def post uri,parameters
	end

	def self.client
		Mobile::Client.new
	end
	
end