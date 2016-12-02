class Parser::WorldConfig < Parser::Abstract

  def parse(screen)

    carry_position = nil
    speed_position = nil
    attack_position = nil

    screen.units = @page.search('img[src*=spear]').first.parents(3).search('> tr').each_with_index.map do |line,index|
      if (index == 0)
        images = line.search('img')
        carry_position = images.index(line.search('img[src*=booty]').first)
        speed_position = images.index(line.search('img[src*=speed]').first)
        attack_position = images.index(line.search('img[src*=att]').first)
        nil
      else
        unit = Unit.new
        unit.cost = Resource.new
        unit.cost.wood = line.search('td')[1].text.to_i
        unit.cost.stone = line.search('td')[2].text.to_i
        unit.cost.iron = line.search('td')[3].text.to_i
        unit.population = line.search('td')[4].text.to_i
        unit.name = line.search('img').first.attr('src').scan(/unit_(.+)\.png/).first.first
        unit.label = line.search('img').first.attr('title')
        unit.carry = line.search('td')[carry_position+5].text.strip.to_i
        unit.attack = line.search('td')[attack_position+5].text.strip.to_i
        unit.general_defense = line.search('td')[attack_position+6].text.strip.to_i
        unit.cavalry_defense = line.search('td')[attack_position+7].text.strip.to_i
        unit.speed = line.search('td')[speed_position+5].text.strip.to_i
        unit
      end
    end 
    screen.units = screen.units.compact
  end

end