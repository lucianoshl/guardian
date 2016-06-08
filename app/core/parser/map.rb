class Parser::Map < Parser::Abstract

  def parse screen
    screen.villages = []

    JSON.parse(@page.body).each do |item|
      villages = item['data']['villages']

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
            player_id: info[4].to_i.zero? ? nil : info[4].to_i
          })
        end
      end
    end
    
    screen.villages = screen.villages.uniq
  end
  
end