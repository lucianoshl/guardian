class Parser::Place < Parser::Abstract

  def parse screen
      screen.form = @page.forms.first
      screen.units = {}

      @page.search('.unit_link').each do |unit_r|
        unit_r = unit_r.parent
        unit_qte = unit_r.search('a').last.text.extract_number
        unit_name = unit_r.search('a').last.attr('href').scan(/unit_input_(.*?)'/).flatten.first
        screen.units[unit_name.to_sym] = unit_qte
      end

      screen.units = Troop.new(screen.units)

      has_commands = @page.search('.quickedit-label').size > 0

      screen.commands = []

      if has_commands
        rows = @page.search('.quickedit-label').first.parents(6).search('tr')
        rows.shift
        screen.commands = (rows.map do |row|
          # command = Command.new
          command = OpenStruct.new
          command.returning = row.search('img').first.attr('src').scan('return_').length > 0
          coordinate = row.search('.quickedit-label').to_coordinate
          command.target =  Village.where(coordinate).first
          command.id = row.search('a').first.attr('href').scan(/id=(\d+)/).extract_number
          command.occurence = row.search('td')[1].text.parse_datetime
          command
        end).sort!{|a,b| a.occurence <=> b.occurence}
      end
    
  end

end