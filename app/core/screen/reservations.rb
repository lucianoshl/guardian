class Screen::Reservations < Screen::Basic

  attr_accessor :reserves,:reserve_form,:reserve_search_form,:forms

  url screen:'ally',mode:'reservations'

  def do_reserve(village)
    forms[2]['x[]'] = village.x
    forms[2]['y[]'] = village.y
    # forms[2]['target_type'] = 'coord'
    # forms[2]['input'] = "#{village.x}|#{village.y}"
    parse(forms[2].submit)
  end

  def cancel_reserve(reserve)
    request(reserve.cancel_url)
  end

  def search_reserve(x,y)
    reserve_form['reservation_search'] = 1
    reserve_form['filter'] = "#{x}|#{y}"
    reserve_form['x'] = nil
    reserve_form['y'] = nil
    reserve_form['group_id'] = 'village_coords'
    parse(reserve_form.submit)
    return reserves.first
  end

end