first_execution = User.where(name: ENV["TW_USER"]).count.zero?

if (first_execution)

	if (User.where(name: ENV["TW_USER"]).count.zero?)
		User.save_user
	end

	user = User.where(name: ENV["TW_USER"]).first
	if (user.player.nil?)

		player_id = Mechanize.my.get("https://#{user.world}.tribalwars.com.br/guest.php?screen=ranking&mode=player&name=#{user.name}").body.scan(/screen=info_player.*?id=(\d+)/).first.first.to_i

		player_info_page = Mechanize.my.get("https://#{user.world}.tribalwars.com.br/guest.php?screen=info_player&id=#{player_id}")

		x,y = player_info_page.body.scan(/\d{3}\|\d{3}/).first.split("|").map(&:to_i)


		Task::PlayerMonitor.new.run([Village.new(x: x, y: y)])
	  	Task::UpdateDailyInformation.new.update_ally_partners
		
		user.player = Player.find_by(name: user.name)
		user.save
	end

	Screen::WorldConfig.new.units.map(&:save) if (Unit.count.zero?)

	Metadata::Building.populate
end