class Mobile::Client

	@@global = nil

	def initialize
		@client = Mobile::Client.create_new_client
	end

	def get uri,parameters = {}
		uri = uri + "?" + parameters.to_query if (parameters.size > 0)
		puts("#{uri}")
		@client.get(uri)
	end

	def post uri,parameters
		puts("#{uri} #{parameters}")
		binding.pry if (parameters.empty?)
		uri = hash(uri,parameters)
		@client.post(uri,parameters.to_json)
	end

	def hash uri,parameters
		_hash = Digest::SHA1.hexdigest("2sB2jaeNEG6C01QOTldcgCKO-"+parameters.to_json)
		uri += (uri.include?('?') ? '&' : '?')
		"#{uri}hash=#{_hash}"
	end

	def self.client
		@@global = Mobile::Client.create_new_client if (@@global.nil?)
		return @@global
	end

	def sid
	    sid_cookie = @client.cookies.select{|a| a.name == 'sid'}.first
	    binding.pry if (sid_cookie.nil?)
	    sid_cookie.value.gsub('0%3A','')
	end

	def cookies
		@client.cookies
	end

	def login
		Rails.logger.info("Login: start")
		MobileCookie.do_login
		@client = Mobile::Client.create_new_client
		Rails.logger.info("Login after  SID: #{sid}")
		Rails.logger.info("Login: end")
	end

	def self.create_new_client
		_client = Mechanize.new
		_client.user_agent = "Mozilla/5.0 (Linux; Android 4.4.4; SAMSUNG-SM-N900A Build/tt) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36"
		_client.add_cookies(MobileCookie.latest)
		return _client
	end
	
end