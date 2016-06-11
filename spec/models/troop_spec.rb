require 'rails_helper'

RSpec.describe Troop, type: :model do
  it "do_login" do
  	# pillage = 100
  	# place_troop = Troop.new(spear: 100, sword: 100)
  	# troop =  place_troop.distribute(pillage)
  	# troop =  troop.upgrade(place_troop - troop,pillage)
  	# troop =  troop.upgrade(place_troop - troop,pillage)
  	puts Troop.new(sword:7).upgrade(Troop.new(spear:1),105).inspect
  	# puts troop
    # map_screen = Screen::Map.neighborhood(OpenStruct.new(x: 534, y: 534),10)
  end
end
