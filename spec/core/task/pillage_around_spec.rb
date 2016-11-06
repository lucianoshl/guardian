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
    # Job::SendAttack.new(event_time: Time.zone.now + 9.minutes + 5.seconds,troop: Troop.new(spy: 5),coordinate: '398|413',origin: Village.where(x:399,y:413).first).execute
  end

end
