require 'rails_helper'

RSpec.describe do

  it "generate_players" do
    # binding.pry
    Utils::PlayerGenerator.new.run
    # Task::UpgradeKnight.new.test_local

    # Utils::PlayerGenerator.new.grow_accounts
  end

end

