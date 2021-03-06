class Mobile::Base < Mobile::Abstract

	attr_accessor :sid

	base "https://#{ENV['TW_WORLD']}.tribalwars.com.br"

	end_point 'm/g'

	# Mobile::Client.client.add_cookies(MobileCookie.latest)

	def before_request args
		sid = self.client.sid
		if (!sid.nil? && args.first != sid)
			args.unshift(sid)
		end
	end

	def get(args)
		request = client.get(generate_url,args)
		if (request.uri.to_s.include?("sid_wro"))
			# MobileCookie.do_login.first.value.gsub('0%3A','')
			client.login
			request = client.post(generate_url,args)
		end
		return request
	end

	def post(args)
		request = client.post(generate_url,args)
		if (request.body.include?("invalidsession"))
			args.unshift
			client.login
			# MobileCookie.do_login.first.value.gsub('0%3A','')
			before_request(args)
			request = client.post(generate_url,args)
		end
		return request
	end

end
