class Screen::Train < Screen::Basic

  attr_accessor :current_units,:total_units,:production_units,:release_time,:train_info

  url screen: 'train'

end