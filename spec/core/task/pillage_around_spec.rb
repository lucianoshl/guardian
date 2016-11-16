require 'rails_helper'

class Dummy

end

RSpec.describe Task::PillageAround, type: :model do
  it "pillage_test_local" do 
    # Mobile::ReportList.load_all
    # Task::PillageAround.new.test_local
    # Task::AutoRecruit.new.test_local
    # Task::UpdateDailyInformation.new.test_local
    # Task::RunTribalWarsEvent.new.test_local
    # screen = Screen::Main.new
    # Dummy.new.run

    Job::SendAttack.new(event_time: Time.zone.now + 9.minutes + 30.seconds,troop: Troop.new(spy: 5, snob: 4, axe: -1,light: -1, knight: -1),coordinate: '393|404',origin: Village.where(x:395,y:413).first).execute
  end

end 
