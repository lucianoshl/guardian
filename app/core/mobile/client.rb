class Mobile::Client

	@@global = Mechanize.new

    @@global.user_agent = "Mozilla/5.0 (Linux; Android 4.4.4; SAMSUNG-SM-N900A Build/tt) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36"

    @@global.set_proxy("localhost", 8081)
    @@global.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    @@global.add_cookies(MobileCookie.latest)

	def initialize
		@client = @@global
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
		@@global
	end
	
end