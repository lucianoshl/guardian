class Mobile::Login < Mobile::Abstract

	attr_accessor :token,:player_id

	def parse page
		self.token = page["result"]["token"]
		self.player_id = page["result"]["player_id"]
	end

	def self.from_user user=User.current
		Mobile::Login.new(user.name,user.password,"2.7.8")
	end
end