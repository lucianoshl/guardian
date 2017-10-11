class Client::Logged

	@@global_client = {}

	def self.client(inner_client = Client::Desktop)
		if (@@global_client[inner_client].nil?)
			@@global_client[inner_client] = inner_client.new
		end
		return @@global_client[inner_client]
	end

	def initialize(inner_client = Client::Desktop)
		@inner_client = Client::Logged.client(inner_client)

	end

	def get(uri,headers={})
		check_cookies
		page = @inner_client.get(uri,headers)
		if (!@inner_client.is_logged?(page))
			cookies = @inner_client.do_login
			Cookie.store_cookies(cookies)
			page = @inner_client.get(uri,headers)
			raise Exception.new("Erro na logica de re-login") if (!@inner_client.is_logged?(page))
		end
		return page
	end

	def post(uri,parameters,headers={})
		check_cookies
		page = @inner_client.post(uri,parameters,headers)
		if (!@inner_client.is_logged?(page))
			cookies = @inner_client.do_login
			MobileCookie.store_cookies(cookies)
			page = @inner_client.post(uri,parameters,headers)
			raise Exception.new("Erro na logica de re-login") if (!@inner_client.is_logged?(page))
		end
		return page
	end
 
	def check_cookies
		if (@inner_client.client.cookies.empty?)
			@inner_client.client.add_cookies(MobileCookie.latest)
		end
	end


	def inner_client 
		@inner_client 
	end

end