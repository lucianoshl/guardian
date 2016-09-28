require 'rails_helper'

class Dummy
	def run
		Village.my.map do |village|
			build(village)
		end
	end

	def build village
		train_screen = Screen::Train.new(id: village.vid)
		binding.pry
	end
end

RSpec.describe Task::PillageAround, type: :model do
  it "pillage_test_local" do 
    # Task::PillageAround.new.test_local
    # Task::UpdateDailyInformation.new.test_local
    # Task::PlayerMonitor.new.test_local
    # Dummy.new.run
  end

end
