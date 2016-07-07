require 'rails_helper'

RSpec.describe  do
  it "dev_socket" do
    # $requests = 0
    # def socketio_time
    #     r = (Time.now.to_f * 1000).round.to_s + "-" + $requests.to_s
    #     $requests += 1
    #     return r
    # end

    # screen = Screen::Place.new

    # host,port,session,rememberUpgrade = screen.websocket_config
    # screen_name = 'place'

    # client = Mechanize.new.add_cookies(Cookie.latest)


    # raw_json = client.get("https://#{host}:#{port}/socket.io/?sessid=#{session}&village_id=#{screen.village.vid}&screen=#{screen_name}&EIO=3&transport=polling&r=#{socketio_time}").body
    # json = JSON.parse(raw_json.scan(/{.*}/).first)

    # raw_json = Mechanize.new.post("https://#{host}:#{port}/socket.io/?sessid=#{session}&village_id=#{screen.village.vid}&screen=#{screen_name}&EIO=3&transport=polling&r=#{socketio_time}&sid=#{json["sid"]}").body

    
    # opts = {
    #     sessid: session,
    #     village_id: screen.village.vid,
    #     screen: screen_name,
    #     EIO: 3,
    #     sid: json["sid"],

    # }
    # socket = SocketIO::Client::Simple.connect( "wss://#{host}:#{port}" , opts )

    # gamejs_source = Mechanize.new.get(screen.gamejs_path).body

    # handlers = gamejs_source.scan(/;Connection.handlers\.(.+?)=/).flatten


    
    # # opts = {
    # #   query: "sessid=#{session}&village_id=#{screen.village.id}&screen=place",
    # #   rememberUpgrade: rememberUpgrade
    # # }

    # # socket_url = "https://#{host}:#{port}/game"

    # # socket_url = "wss://br76.tribalwars.com.br:8081/socket.io/?sessid=8be83b845784&village_id=35200&screen=train&EIO=3&transport=websocket&sid=Fg5G15-oHUB_eHqIAwC2"


    # # puts "socket_url = #{socket_url}"

    # # # socket = SocketIO::Client::Simple.connect( socket_url , opts )
    # # socket = WebSocket::Client::Simple.connect(socket_url)



    # socket.on :connect do
    #   puts "connect!!! #{Time.zone.now}"
    # end

    # socket.on :open do
    #   puts "open!!! #{Time.zone.now}"
    # end
    # socket.on :connect_error do
    #   puts "connect_error!!! #{Time.zone.now}"
    # end
    # socket.on :disconnect do
    #   puts "disconnect!!! #{Time.zone.now}"
    # end
    # socket.on :error do
    #   puts "error!!! #{Time.zone.now}"
    # end

    # socket.on :error do |err|
    #   p err
    # end

    # handlers.map do |name|
    #   socket.on name.to_sym do |*args|
    #     puts "event!!! #{Time.zone.now} args=#{args.size} args=#{args}"
    #   end
    # end

    # puts "start loop"

    # loop {}

  end
end
