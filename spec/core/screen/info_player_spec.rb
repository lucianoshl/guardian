require 'rails_helper'

RSpec.describe Screen::InfoPlayer , type: :model do
  it "player_without_ally" do
  	Screen::InfoPlayer.new(id: 919187962) 
  end
end
