require 'rails_helper'

RSpec.describe do

  it "logout" do
    troops = Troop.new(sword: 1, light: 1)
    puts troops.win?(0,0,true)
    puts troops.win?(0,0,false)
  end

end
