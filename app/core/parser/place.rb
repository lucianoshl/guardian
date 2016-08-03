class Parser::Place < Parser::Basic

  def parse screen
    super
    screen.form = @page.forms.first
    screen.units = {}

    @page.search('.unit_link').each do |unit_r|
      unit_r = unit_r.parent
      unit_qte = unit_r.search('a').last.text.extract_number
      unit_name = unit_r.search('a').last.attr('href').scan(/unit_input_(.*?)'/).flatten.first
      screen.units[unit_name.to_sym] = unit_qte
    end

    screen.units = Troop.new(screen.units)

    screen.commands = parse_commands(screen,@page.search('a[href*=own]'))
    screen.incomings = parse_commands(screen,@page.search('a[href*=other]').select{|a| !a.to_xml.include?('support.png')}) 

    if (`hostname`.strip == "overmind")
      fake = OpenStruct.new
      fake.returning = false
      fake.id = 0
      fake.target = Village.last
      fake.origin = Village.my.first
      fake.occurence = Time.zone.now + 1.hour
      screen.incomings = [fake]
    end

    screen.supports = parse_commands(screen,@page.search('a[href*=other]').select{|a| a.to_xml.include?('support.png')})
    
  end

  def parse_commands screen,links
    (links.map do |row|
      row = row.parents(4)
      command = OpenStruct.new
      command.returning = row.search('img').first.attr('src').scan('return_').length > 0
      coordinate = row.search('.quickedit-label').to_coordinate
      command.id = row.search('a').first.attr('href').scan(/id=(\d+)/).extract_number

      if (coordinate.x == 0 && coordinate.y == 0)
        screen = Screen::InfoCommand.new(id: command.id)
        command.target = screen.target
        command.origin = screen.origin
      else
        command.target =  Village.where(coordinate).first
        if (command.target.nil?)
          screen = Screen::InfoCommand.new(id: command.id)
          command.target = screen.target
        end
        command.origin = screen.village
      end

      binding.pry if (command.target.nil? || command.origin.nil?)

      command.occurence = row.search('td')[1].text.parse_datetime
      if (!row.search('.command-cancel').first.nil?)
        command.cancel_url = row.search('.command-cancel').first.attr('href')
      end
      command
    end).sort!{|a,b| a.occurence <=> b.occurence}
  end

end
