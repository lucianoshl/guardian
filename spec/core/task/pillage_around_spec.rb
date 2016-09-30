require 'rails_helper'

class Dummy

end

RSpec.describe Task::PillageAround, type: :model do
  it "pillage_test_local" do 
    Task::PillageAround.new.test_local
    # Task::UpdateDailyInformation.new.test_local
    # Task::PlayerMonitor.new.test_local
    # Dummy.new.run
  end

end
