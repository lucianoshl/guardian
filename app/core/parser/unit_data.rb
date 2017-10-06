class Parser::UnitData < Parser::Abstract

  def parse(screen)
    screen.units = JSON.parse(@page.body)["unit_data"].map do |name,info|
      unit = Unit.new
      unit.name = name
      unit.label = info["name"] 
      unit.carry = info["carry"] 
      unit.attack = info["attack"] 
      unit.general_defense = info["defense"]  
      unit.cavalry_defense = info["defense_cavalry"]   
      unit.population = info["pop"]   
      unit.speed = info["speed"]   
      unit
    end
  end

end
