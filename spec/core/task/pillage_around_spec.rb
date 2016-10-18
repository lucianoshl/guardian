require 'rails_helper'

class Dummy

end

RSpec.describe Task::PillageAround, type: :model do
  it "pillage_test_local" do 
    # Mobile::ReportList.load_all
    Task::PillageAround.new.test_local
    # Task::AutoRecruit.new.test_local
    # Task::UpdateDailyInformation.new.test_local
    # Task::RunTribalWarsEvent.new.test_local
    # screen = Screen::Main.new
    # Dummy.new.run
  end

end
