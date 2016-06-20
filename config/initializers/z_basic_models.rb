
if (User.where(name: ENV["TW_USER"]).count.zero?)
	User.save_user
end

user = User.where(name: ENV["TW_USER"]).first
if (user.player.nil?)

	player_id = Mechanize.my.get("https://#{user.world}.tribalwars.com.br/guest.php?screen=ranking&mode=player&name=#{user.name}").body.scan(/screen=info_player.*?id=(\d+)/).first.first.to_i

	player_info_page = Mechanize.my.get("https://#{user.world}.tribalwars.com.br/guest.php?screen=info_player&id=#{player_id}")

	x,y = player_info_page.body.scan(/\d{3}\|\d{3}/).first.split("|").map(&:to_i)

	Task::PlayerMonitor.new.run(Village.new(x: x, y: y))
	
	user.player = Player.find_by(name: user.name)
	user.save
end

if (Unit.count.zero?)
	screen = Screen::Place.new
	raw_screen = screen.request("https://#{User.current.world}.tribalwars.com.br/game.php?screen=unit_info") 
	json = JSON.parse(raw_screen.body.scan(/UnitPopup.unit_data = ({.*})/).first.first)

	json.map do |key,value|
		unit = Unit.new
		unit.label = value["name"]
		unit.name = key
		unit.type = value["type"]
		unit.carry = value["carry"] 
		unit.attack = value["attack"] 
		unit.speed = value["speed"] 
		unit.cost = Resource.new(wood: value["wood"],stone: value["stone"],iron: value["iron"])
		unit.save
	end
end