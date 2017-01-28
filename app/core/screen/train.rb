class Screen::Train < Screen::Basic

  attr_accessor :current_units,:total_units,:production_units,:release_time,:train_info,:_snob_related

  url screen: 'train'

  def train(troops)
  	Rails.logger.info("Training #{troops.to_h}")
  	url = "https://#{User.current.world}.tribalwars.com.br/game.php?village=#{village.vid}&screen=train&ajaxaction=train&mode=train&h=#{csrf_token}&client_time=1475162919"

  	parameters = { units: troops.to_h }

  	result = client.post(url,parameters)
  end

  def complete_units
    complete_units = {}
    production_units.values.map{|a| complete_units.merge!(a)}
    complete_units = Troop.new(total_units) + complete_units
    complete_units.snob = (snob_screen.total_snob || 0) + snob_screen.queue_size

    return complete_units
  end

  def snob_screen
    self._snob_related = Screen::Snob.new(village: self.village.vid) if (self._snob_related.nil?)
    self._snob_related
  end

end