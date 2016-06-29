class Parser::Basic < Parser::Abstract

  def parse screen

    if (!@page.search('#bot_check').empty?)
      raise Exception.new('bot protection')
    end

    json = JSON.parse(@page.body.scan(/TribalWars.updateGameData\(({.*})/).first.first)
    screen.player_id = json["player"]["id"].to_i

    screen.village = Village.my.where(vid: json["village"]["id"]).first

    screen.logout_url = @page.search('a[href*=logout]').first.attr('href')
    screen.resources = Resource.new(wood: json["village"]["wood"], stone: json["village"]["stone"], iron: json["village"]["iron"])
    screen.storage_size = json["village"]["storage_max"]

    screen.websocket_config = @page.body.scan(/Connection.connect\((.*?)\)/).flatten.first.gsub("'",'').split(', ')

    screen.gamejs_path = @page.body.scan(/http.+mobile.js/).first.gsub('mobile','game')

  end

end