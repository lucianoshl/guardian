class Screen::UnitData < Screen::Logged
  
  attr_accessor :units
  url screen: 'unit_info', ajax: 'data'

end