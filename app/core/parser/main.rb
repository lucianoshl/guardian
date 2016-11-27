class Parser::Main < Parser::Basic

  def parse screen
    super
    screen.buildings_meta_json = buildings_meta_json = JSON.parse(@page.body.scan(/BuildingMain.buildings = ({.+})/).first.first)

    screen.buildings_metadata = {}

    buildings_meta_json.map do |name,value|
      building = screen.buildings_metadata[name] = Metadata::Building.new
      building.name = name
      building.label = value["name"]
      building.max_level = value["max_level"] 
      building.min_level = value["min_level"] 

      building.wood_factor = value["wood_factor"]
      building.stone_factor = value["stone_factor"]
      building.iron_factor = value["iron_factor"]
      building.pop_factor = value["pop_factor"]
      building.build_time_factor = value["build_time_factor"]

      level_next = value["level_next"].to_i 

      building.wood = (value["wood"]/(building.wood_factor ** (level_next - 1))).round
      building.stone = (value["stone"]/(building.stone_factor ** (level_next - 1))).round
      building.iron = (value["iron"]/(building.iron_factor ** (level_next - 1))).round
    end

    screen.queue = (@page.search('.queueItem').map do |line| 
      item = OpenStruct.new
      item.building = line.search('img').attr('src').value.scan(/\/([a-z]+)\d*.png/).first.first
      item.completed_in = line.search('div')[3].text.strip.split(' - ').last.parse_datetime
      item
    end).sort{|a,b| a.completed_in <=> b.completed_in }

    screen.buildings = buildings = {}
    information = JSON.parse(@page.body.scan(/BuildingMain.buildings = ({.*})/).first.first).each do |id,information|
      buildings[id] = building = OpenStruct.new(information)
      build_element = @page.search("#main_buildlink_#{building.id}_#{building.level_next}")
      building.build_possible = build_element.empty? ? false : build_element.attr('style').nil?
      building.level = building.level.to_i
      building.in_queue = screen.queue.map(&:building).include?(id)
      building.name = id
    end

    # game_data = JSON.parse page.body.scan(/game_data = ({.*})/).first.first

    # all_buildings = game_data["village"]["buildings"]

    # self.buildings.keys.concat(["village"]).each{|a| all_buildings.delete a }

    # all_buildings.each do |id,level|
    #   building = Building.new
    #   build_element = page.search("#main_buildlink_#{building.id}_#{building.level_next}")
    #   building.id = id
      
    #   if (!page.search("img[src*='/#{id}']").first.nil?)
    #     building.name = page.search("img[src*='/#{id}']").first.attr('title')
    #   end

    #   building.level = level.to_i
    #   building.build_possible = build_element.empty? ? false : build_element.attr('style').nil?
    #   building.in_queue = page.search(".buildorder_#{building.id}").size > 0
    #   self.buildings[id] = building
    # end
  end

end