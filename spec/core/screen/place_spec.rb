require 'rails_helper'

RSpec.describe Screen::Place , type: :model do
  it "test_save_troops" do
  	Village.my.map do |my|
  		place = Screen::Place.get_free(my.vid)
  		puts place.units.attributes
  	end
		
  end
end
