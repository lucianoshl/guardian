require 'rails_helper'

RSpec.describe Troop, type: :model do
  it "upgrade_troops_1" do
    puts Troop.new(spear: 1,sword: 5).distribute(100).upgrade(Troop.new(light:1),100).inspect
  end

  it "troop-" do
    expect((Troop.new(spear: 5) - Troop.new(spear: 5)).spear).to equal(0)

    expect((Troop.new(spear: 5 ,sword: 5) - Troop.new(spear: 5)).sword).to equal(5)
  end
end
