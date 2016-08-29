class Screen::Map < Screen::Guest

  attr_accessor :villages

  endpoint '/map.php'
  url screen: 'map', v: 2

  def self.neighborhood villages,distance
    targets = {}

    villages.map do |village|
      squares = (distance / 20) + 1

      start_x = (village.x / 20) * 20 - 20 * squares
      start_y = (village.y / 20) * 20 - 20 * squares

      size = (squares * 2 + 1)

      targets = {}

      for i in (0..size - 1)
        for j in (0..size - 1)
          x = start_x + (i * 20)
          y = start_y + (j * 20)
          targets["#{x.to_i}_#{y.to_i}"] = 1
        end
      end 
    end
    
    return Screen::Map.new(targets)
  end
  
end