class Screen::Main < Screen::Basic

  attr_accessor :buildings_metadata,:queue,:buildings,:buildings_meta_json

  url screen: 'main'  

  def build(name)
  	base = "https://#{User.current.world}.tribalwars.com.br"
  	build_link = base + buildings_meta_json[name]['build_link'].gsub('&amp;','&')
  	parse(client.get(build_link))
  	last_building = queue.last
  	return last_building.completed_in
  end

end