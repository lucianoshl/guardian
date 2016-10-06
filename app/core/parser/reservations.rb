class Parser::Reservations < Parser::Basic

  def parse screen
    super
    itens = @page.search('#reservations').search('tr')
    itens.shift
    itens.pop
    screen.reserves = itens.map do |line| 
      reserve = OpenStruct.new
      reserve.village = line.search('a:first').text.to_coordinate
      reserve_link = line.search('a[href*=delete_reservation]')
      reserve.cancel_url = line.search('a[href*=delete_reservation]').last.attr('href') if (!reserve_link.empty?)
      reserve.expiration_time = line.search('.more_info p:last').text.split('o:').last.parse_datetime
      reserve
    end
    screen.reserve_search_form = @page.forms[2]
    screen.reserve_form = @page.forms[3]
  end

end