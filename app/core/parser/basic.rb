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

    screen.current_population,screen.limit_population = @page.search("#pop_current_label").first.parent.text.split('/').map(&:to_i)

    screen.free_population = screen.limit_population - screen.current_population

    screen.farm_alert = screen.current_population/screen.limit_population.to_f > 0.85
    
    screen.storage_alert = screen.resources.attributes.values.select{|a| a.class == Fixnum}.max/screen.storage_size.to_f > 0.85

    screen.building_levels = json["village"]["buildings"]

  end

end