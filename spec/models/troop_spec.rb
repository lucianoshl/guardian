require 'rails_helper'

RSpec.describe Troop, type: :model do
  it "do_login" do
    puts Troop.new(spear: 1,sword: 5).distribute(100).upgrade(Troop.new(knight:1),100).inspect
  end
end
