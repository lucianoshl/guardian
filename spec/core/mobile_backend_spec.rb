# require 'rails_helper'

# class MobileClient

#   def initialize
#     @server = 'https://www.tribalwars.com.br'
#     @client = Mechanize.new
#     @client.set_proxy("localhost", 8080)
#     @client.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#     @client_version = 1410
#     @client.user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 9_3_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13G34 (Tribal Wars 2.4 rv:#{@client_version})"

#     @headers = {
#       'Content-Type'    => 'application/json'
#     }

#   end

#   def login(user)
#     world_url = "#{@server}/backend/mobile/master.php?action=login&hash=93162ac83798be5deb3c60b18b97d020f23e9fa4"
#     parameters = [
#       user.name,
#       user.password,
#       @client_version.to_s
#     ]

#     result = post(world_url,parameters)

#     r = post("https://www.tribalwars.com.br/backend/mobile/master.php?action=push_token&hash=76330b8c473b166ac987f7062b012630ae623caf",[
#         result["result"]["token"],
#         "e564cad7f8b72da4e109ce15ea69eb6bd994e759f10a30486196c8177b68b15f",
#         "0F102567-A4E4-4943-A9EA-0D19C0AA4EC4",
#         "iPhone 5 9.3.3"
#       ])

#     binding.pry 

#     login_url = "https://#{user.world}.tribalwars.com.br/backend/mobile/game.php?action=login&hash=57eeed3e5b21760bc5b8b5301cfce268bdcbaa5b"

#     puts result["result"]["token"]

#     parameters = [
#       result["result"]["token"],
#       "2"
#     ]

    


#     binding.pry

#   end

#   def post(url,parameters)
#     JSON.parse(@client.post(url,parameters.to_json,@headers).body)
#   end

# end

# RSpec.describe do

#   it "mobile-login" do
#     client = MobileClient.new
#     client.login(User.current)
#   end

# end

