require 'rails_helper'

RSpec.describe  do
  it "dev_socket" do
    # screen = Screen::Place.new
    # host,port,session,rememberUpgrade = screen.websocket_config

    # gamejs_source = Mechanize.new.get(screen.gamejs_path).body

    # handlers = gamejs_source.scan(/;Connection.handlers\.(.+?)=/).flatten

    
    # opts = {
    #   query: "sessid=#{session}&village_id=#{screen.village.id}&screen=place",
    #   rememberUpgrade: rememberUpgrade
    # }

    # socket_url = "https://#{host}:#{port}/game"

    # socket_url = "wss://br76.tribalwars.com.br:8081/socket.io/?sessid=8be83b845784&village_id=35200&screen=train&EIO=3&transport=websocket&sid=Fg5G15-oHUB_eHqIAwC2"


    # puts "socket_url = #{socket_url}"

    # # socket = SocketIO::Client::Simple.connect( socket_url , opts )
    # socket = WebSocket::Client::Simple.connect(socket_url)



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
