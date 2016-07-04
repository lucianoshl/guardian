class Task::UpdateDailyInformation < Task::Abstract

  run_daily 12

  def run
    update_ally_partners
    renew_village_reserve
  end

  def update_ally_partners
    my_ally = User.current.player.ally
    return if (my_ally.nil?)
    my_ally.partners = Ally.in(aid: Screen::AllyContracts.new.allies).to_a
    my_ally.save
  end

  def renew_village_reserve
  end

end
