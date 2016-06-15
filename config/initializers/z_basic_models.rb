$pid = 0


if (!User.current.nil? && User.current.player.nil?)
	user = User.current

	player_id = Mechanize.new.get("https://#{user.world}.tribalwars.com.br/guest.php?screen=ranking&mode=player&name=#{user.name}").body.scan(/screen=info_player.*?id=(\d+)/).first.first.to_i

	player_info_page = Mechanize.new.get("https://#{user.world}.tribalwars.com.br/guest.php?screen=info_player&id=#{player_id}")

	x,y = player_info_page.body.scan(/\d{3}\|\d{3}/).first.split("|").map(&:to_i)

	Task::PlayerMonitor.new.run(Village.new(x: x, y: y))
	
	user.player = Player.find_by(name: user.name)
	user.save
end

if (Unit.count.zero?)
	screen = Screen::Place.new
	raw_screen = screen.request(screen.gen_url())
	json = JSON.parse(raw_screen.body.scan(/UnitPopup.unit_data = ({.*})/).first.first)

	json.map do |key,value|
		unit = Unit.new
		unit.label = value["name"]
		unit.name = key
		unit.type = value["type"]
		unit.carry = value["carry"] 
		unit.attack = value["attack"] 
		unit.speed = value["speed"] 
		unit.save
	end
end