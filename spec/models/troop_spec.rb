require 'rails_helper'

RSpec.describe Troop, type: :model do
  it "upgrade_troops_1" do
    puts Troop.new(spear: 1,sword: 5).distribute(100).upgrade(Troop.new(light:1),100).inspect
  end

  it "troop-" do
    expect((Troop.new(spear: 5) - Troop.new(spear: 5)).spear).to equal(0)

    expect((Troop.new(spear: 5 ,sword: 5) - Troop.new(spear: 5)).sword).to equal(5)
  end

  it "troop_increase_poulation" do

    troop = Troop.new({"spear"=>0, "spy"=>4, "light"=>1})
    disponible = Troop.new({"spear"=>514, "sword"=>362, "axe"=>0, "archer"=>0, "ram"=>0, "catapult"=>0, "spy"=>218, "light"=>1, "marcher"=>0, "heavy"=>0, "knight"=>0, "snob"=>0, "militia"=>0})
    target_population = 91

    troop.increase_population(disponible,target_population)
  end
end
