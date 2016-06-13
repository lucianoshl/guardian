class Parser::Main < Parser::Basic

  def parse screen
    super
    queue = (@page.search("tr[class*='buildorder']").map do |line|
      item = OpenStruct.new
      item.building = line.attr('class').scan(/buildorder_(.+)/).first.first
      item.completed_in = line.search('.btn-cancel').first.parent.previous_element.text.parse_datetime
      item
    end).sort{|a,b| a.completed_in <=> b.completed_in }

    buildings = {}
    information = JSON.parse(@page.body.scan(/BuildingMain.buildings = ({.*})/).first.first).each do |id,information|
      buildings[id] = building = OpenStruct.new#(information)
      build_element = @page.search("#main_buildlink_#{building.id}_#{building.level_next}")
      building.build_possible = build_element.empty? ? false : build_element.attr('style').nil?
      building.level = building.level.to_i
      building.in_queue = queue.map(&:building).include?(id)
      building.name = id
    end

    binding.pry
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