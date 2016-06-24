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
    screen.supports = parse_commands(screen,@page.search('a[href*=other]').select{|a| a.to_xml.include?('support.png')})
    
  end

  def parse_commands screen,links
    (links.map do |row|
      row = row.parents(4)
      command = OpenStruct.new
      command.returning = row.search('img').first.attr('src').scan('return_').length > 0
      coordinate = row.search('.quickedit-label').to_coordinate
      if (coordinate.x == 0 && coordinate.y == 0)
        command_id = row.search('a').attr('href').text.scan(/id=(\d+)/).first.first
        screen = Screen::InfoCommand.new(id: command_id)
        command.target = screen.target
        command.origin = screen.origin
      else
        command.target =  Village.where(coordinate).first
        command.origin = screen.village
      end
      command.id = row.search('a').first.attr('href').scan(/id=(\d+)/).extract_number
      command.occurence = row.search('td')[1].text.parse_datetime
      command
    end).sort!{|a,b| a.occurence <=> b.occurence}
  end

end