class Client::Desktop

	@@global_client = nil

	def self.client
		if (@@global_client.nil?)
			@@global_client = Mechanize.new
		end
		return @@global_client
	end

	def client
		Client::Desktop.client
	end

	def get(uri,headers={})
		# binding.pry
		client.get(uri,[],nil,headers)
	end

	def post(uri,parameters,headers={})
		client.post(uri,parameters,headers)
	end

	def do_login(user = User.current)
	    base = "https://www.tribalwars.com.br"

	    user.name = user.user if user.respond_to?("user")

	    if (user.password.nil?)
	      user.password = user.name.parameterize + "-12345"
	    end

	    select_world_page = client.post("#{base}/index.php?action=login&show_server_selection=1",{
	      user: user.name,
	      password: user.password,
	      cookie: true,
	      clear: true
	      });

	    game_screen = client.post("#{base}/index.php?action=login&server_#{User.current.world}",{
	        user: user.name,
	        password: select_world_page.body.scan(/password.*?value=\\\"(.*?)\\/).first.first,
	        })
	    client.cookies
	end

	def is_logged?(page)
		!page.uri.to_s.include?('sid_wrong.php')
	end

end