class Screen::Main < Screen::Basic

  attr_accessor :buildings_metadata,:queue,:buildings,:buildings_meta_json

  url screen: 'main'  

  def build(name)
  	base = "https://#{User.current.world}.tribalwars.com.br"

  	raw_build_link = buildings_meta_json[name]['build_link']

  	if (raw_build_link.nil?)
  		Rails.logger.error("Não foi encontrado build_link para o edificio #{name} #{buildings_meta_json}")
  		raise Exception.new("Não foi encontrado build_link para o edificio #{name}")
  	end

  	build_link = base + raw_build_link.gsub('&amp;','&')
  	parse(client.get(build_link))
  	last_building = queue.first
  	return last_building.completed_in
  end

end