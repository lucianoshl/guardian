class Parser::Basic < Parser::Abstract

  def parse screen

    if (!@page.search('#bot_check').empty?)
      raise Exception.new('bot protection')
    end

    json = JSON.parse(@page.body.scan(/TribalWars.updateGameData\(({.*})/).first.first)
    screen.player_id = json["player"]["id"].to_i

    screen.village = Village.where(vid: json["village"]["id"]).first

    screen.logout_url = @page.search('a[href*=logout]').first.attr('href')
    screen.resources = Resource.new(wood: json["village"]["wood"], stone: json["village"]["stone"], iron: json["village"]["iron"])
    screen.storage_size = json["village"]["storage_max"]

    screen.websocket_config = @page.body.scan(/Connection.connect\((.*?)\)/).flatten.first.gsub("'",'').split(', ')

    screen.gamejs_path = @page.body.scan(/http.+mobile.js/).first.gsub('mobile','game')

    screen.csrf_token = @page.body.scan(/csrf_token = '(.+)'/).first.first

    screen.incomings = json['player']['incomings'].to_i

    current_population,limit_population = @page.search("#pop_current_label").first.parent.text.split('/').map(&:to_i)

    screen.farm_alert = current_population/limit_population.to_f > 0.85

  end

end