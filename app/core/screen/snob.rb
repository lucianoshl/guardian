class Screen::Snob < Screen::Basic

  attr_accessor :possible_coins,:coin_form,:total_snob,:possible_snobs,:enabled,:queue_size,:recruit_url,:possible_recruit

  url screen: 'snob'

  def do_coin(amount)
  	self.coin_form['count'] = amount
  	parse(self.coin_form.submit)
  end

  def train qte
  	return if (!enabled)
  	while(qte != 0 && possible_recruit)
  		parse(client.get(recruit_url))
  		qte -= 1
  	end
  end

end
