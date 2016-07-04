require 'rails_helper'

RSpec.describe Task::PillageAround, type: :model do
  it "pillage_test_local" do 
    Task::PillageAround.new.test_local
  end

  it "move_to_waiting_resources" do
    # Task::PillageAround.new.move_to_waiting_resources(Report.where(_status: :spy).first.target)
  end
end
