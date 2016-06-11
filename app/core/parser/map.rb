class Parser::Map < Parser::Abstract

  def parse screen
    screen.villages = []

    JSON.parse(@page.body).each do |item|
      villages = item['data']['villages']

      players = parse_players(item)

      if (item['data']['villages'].size == 1)
        item['data']['villages'] = villages = [{ "0" => item['data']['villages'].first.first }]
      end

      base_x = item['data']['x']
      base_y = item['data']['y']

      if (villages.class != Hash) then
        villages = Hash[(0...villages.size).zip villages]
      end

      villages.each_with_index do |(key,value), index|
        x = key.to_i
        if (value.class != Hash) then
          value = Hash[(0...value.size).zip value]
        end
        value.each_with_index  do |(key, info), index|
          y = key.to_i
          screen.villages << OpenStruct.new({
            vid: info[0].to_i,
            x: base_x + x.to_i,
            y: base_y + y.to_i, 
            name: info[4].to_i.zero? ? 'Aldeia de bárbaros' : info[2],
            points: info[3].to_i,
            player: players[info[4].to_i]#.zero? ? nil : info[4].to_i
          })
        end
      end
    end
    
    screen.villages = screen.villages.uniq
  end

  def parse_players(item)
    result = {}
    item["data"]["players"].map do  |id,content|
      player = OpenStruct.new
      player.pid = id.to_i
      player.name = content[0]
      player.points = content[1].to_i
      player.ally = parse_ally(content[2],item["data"]["allies"][content[2]])
      result[id.to_i] = player
    end
    return result
  end

  def parse_ally id,content
    return nil if content.nil?
    ally = OpenStruct.new
    ally.aid = id.to_i
    ally.name = content[0]
    ally.points = content[1].extract_number
    ally.short = content[2]
    ally
  end
  
end