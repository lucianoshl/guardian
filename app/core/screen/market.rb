class Screen::Market < Screen::Basic

  attr_accessor :trader,:trade_disponible,:send_resource_form

  url screen: 'market', mode: 'send'

  def send_resource(village,resource)
  	if (!trader.resources_disponible.include?(resource))
  		Rails.logger.info("No resource do send_resource".red.on_white)
  	end

  	Rails.logger.info("Send resource to #{village.to_s}".blue.on_white)

  	send_resource_form['x'] = village.x  
  	send_resource_form['y'] = village.y
  	send_resource_form['wood'] = resource['wood']
  	send_resource_form['stone'] = resource['stone']
  	send_resource_form['iron'] = resource['iron']
  	parse(send_resource_form.submit.forms.first.submit)
  end

end