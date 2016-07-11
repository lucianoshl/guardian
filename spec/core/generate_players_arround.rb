require 'rails_helper'

RSpec.describe do

  it "generate_players" do
    PlayerGenerator.new.run
  end

end

