class Screen::Train < Screen::Basic

  attr_accessor :current_units,:total_units,:production_units,:release_time,:train_info,:_snob_related,:form

  url screen: 'train'

  def train(troops)
    troops = troops.to_h.select{|unit,qte| qte > 0}
    troops.map do |unit,value|
      self.form[unit] = value
    end
  	parse(self.form.submit)
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