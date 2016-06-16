class Parser::Basic < Parser::Abstract

  def parse screen

    if (!@page.search('#bot_check').empty?)
      raise Exception.new('bot protection')
    end

    json = JSON.parse(@page.body.scan(/TribalWars.updateGameData\(({.*})/).first.first)
    screen.player_id = json["player"]["id"].to_i
  end

end