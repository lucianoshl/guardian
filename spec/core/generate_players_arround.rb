require 'rails_helper'

RSpec.describe do

  it "generate_players" do
    # binding.pry
    Utils::PlayerGenerator.new.run
  end

end

