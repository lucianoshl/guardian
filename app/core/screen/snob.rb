class Screen::Snob < Screen::Basic

  attr_accessor :possible_coins,:coin_form,:total_snob,:possible_snobs,:enabled,:queue_size

  url screen: 'snob'

  def do_coin(amount)
  	self.coin_form['count'] = amount
  	parse(self.coin_form.submit)
  end

end
