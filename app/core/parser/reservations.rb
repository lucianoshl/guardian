class Parser::Reservations < Parser::Basic

  def parse screen
    super
    itens = @page.search('#reservations').search('tr')
    itens.shift
    itens.pop
    screen.reserves = itens.map do |line|
      reserve = OpenStruct.new
      reserve.village = Village.where(vid: line.search('a').first.attr('href').scan(/id=(\d+)/).first.first).first
      reserve.cancel_url = line.search('a[href*=delete_reservation]').last.attr('href')
      reserve
    end
    screen.reserve_form = @page.forms[3]
  end

end