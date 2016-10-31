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

	def get(uri)
		check_cookies
		page = @inner_client.get(uri)
		if (!@inner_client.is_logged?(page))
			cookies = @inner_client.do_login
			Cookie.store_cookies(cookies)
			page = @inner_client.get(uri)
			raise Exception.new("Erro na logica de re-login") if (!@inner_client.is_logged?(page))
		end
		return page
	end

	def post(uri,parameters)
		check_cookies
		page = @inner_client.post(uri,parameters)
		if (!@inner_client.is_logged?(page))
			cookies = @inner_client.do_login
			Cookie.store_cookies(cookies)
			page = @inner_client.post(uri,parameters)
			raise Exception.new("Erro na logica de re-login") if (!@inner_client.is_logged?(page))
		end
		return page
	end

	def check_cookies
		if (@inner_client.client.cookies.empty?)
			@inner_client.client.add_cookies(Cookie.latest)
		end
	end

end