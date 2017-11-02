class Task::UpdateDailyInformation < Task::Abstract

  run_daily 12

  def run
    update_ally_partners
    rename_villages
    # renew_village_reserve
    # generate_player_arround
    update_profile_photo
    # clean_information
  end

  def rename_villages
    Rails.logger.info("Renaming all villages: start")
    names = Config.village.v_name(User.current.player.name).split(/,|;/)
    Village.my.asc(:vid).each_with_index.map do |village,index|
      name = names[index%names.size]
      Screen::Main.new(village: village.vid).rename(name) if (village.name != name)
    end
    Rails.logger.info("Renaming all villages: end")
  end

  def update_ally_partners
    return if (User.current.player.nil?)
    my_ally = User.current.player.ally
    return if (my_ally.nil?)
    my_ally.partners = Ally.in(aid: Screen::AllyContracts.new.allies).to_a
    my_ally.save
  end

  def update_profile_photo
    player_info = Screen::InfoPlayer.new(id: User.current.player.pid)

    my_user = User.first
    my_user.avatar_url = player_info.avatar_url
    my_user.save
  end

  def renew_village_reserve
    Utils::RenewVillageReserve.new.run
  end

  def generate_player_arround
    Utils::PlayerGenerator.new.run
  end

  def clean_information
    Rails.logger.info("Cleaning points history: start")
    villages = Village.all.to_a
    villages.each_with_index do |village,i|
      village.points_history = village.points_history.last(20)
      village.save
      Rails.logger.info("#{villages.size}/#{i}")
    end
    Rails.logger.info("Cleaning points history: start")
  end

end
