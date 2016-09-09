class Mobile::WorldLogin < Mobile::Base

	entry :login

	def before_request args
		args
	end

	def parse page
		$sid = page["result"]["sid"]
	end

	def get(args)
		client.get(generate_url,args)
	end

	def post(args)
		client.post(generate_url,args)
	end
end