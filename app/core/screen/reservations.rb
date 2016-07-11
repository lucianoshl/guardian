class Screen::Reservations < Screen::Basic

  attr_accessor :reserves,:reserve_form

  url screen:'ally',mode:'reservations'

  def do_reserve(village)
    reserve_form['x[]'] = village.x
    reserve_form['y[]'] = village.y
    reserve_form['target_type'] = 'coord'
    reserve_form['input'] = "#{village.x}|#{village.y}"
    parse(reserve_form.submit)
  end

  def cancel_reserve(reserve)
    request(reserve.cancel_url)
  end

end