class Parser::Map < Parser::Abstract

  def parse screen
    screen.villages = []

    json = JSON.parse(@page.body)    

    @all_allies = {}

    json.map do |item|
      item["data"]["allies"].map do |k,v|
        @all_allies[k] = v
      end
    end

    json.each do |item|
      villages = item['data']['villages']

      players = parse_players(item)

      if (item['data']['villages'].size == 1)
        item['data']['villages'] = villages = [{ "0" => item['data']['villages'].first.first }]
      end

      base_x = item['data']['x']
      base_y = item['data']['y']

      # debug_base = OpenStruct.new(x: 340, y: 360)
      # binding.pry if (debug_base.x == base_x && debug_base.y == base_y && true)

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

          # binding.pry if (base_x + x.to_i == 682 && base_y + y.to_i == 687)
          if (info.class != Array)
            next
          end


          if (info[7] == '0')
            if (info[4].to_i.zero?)
              village_name = 'Aldeia de bárbaros'
            else
              village_name = info[2]
            end
          elsif (info[7] == '5')
            village_name = 'Empório do feiticeiro'
          elsif
            binding.pry
          end

          screen.villages << OpenStruct.new({
            vid: info[0].to_i,
            x: base_x + x.to_i,
            y: base_y + y.to_i, 
            name: village_name,
            points: info[3].extract_number,
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
      player.points = content[1].extract_number
      player.ally = parse_ally(content[2],@all_allies[content[2]])
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