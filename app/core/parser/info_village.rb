class InexistentVillage < Exception
end

class Parser::InfoVillage < Parser::Abstract

  def parse(screen)
    vid = @page.uri.to_s.scan(/id=(\d+)/).first.first.to_i
    if @page.body.force_encoding("utf-8").include?('aldeia não existe')
      raise InexistentVillage.new("Aldeia com vid=#{vid} não existe")
    end

    screen.village = village = Village.new

    village.vid = @page.uri.to_s.scan(/id=(\d+)/).first.first.to_i
    village.x, village.y = @page.body.scan(/\d{3}\|\d{3}/).first.split("|")

    village.name = @page.search('h2').text.strip
    village.points = @page.search('td > table')[3].search('td')[4].text.extract_number
    village.points_history = []

    village.state = nil
    village.next_event = nil
    
    if (@page.body.scan(/info_player.+id=(\d+)/).size > 0)
      village.player_id = @page.body.scan(/info_player.+id=(\d+)/).extract_number
    else
      village.player_id = nil
    end

    village.is_barbarian = village.player_id.nil?
  end

end