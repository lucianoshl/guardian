require 'rails_helper'

class Dummy
	def run
		Village.my.map do |village|
			build(village)
		end
	end

	def build village
		train_time = 1.hour
		train_until = Time.zone.now + train_time

		train_screen = Screen::Train.new(id: village.vid)
		complete_units = {}
		train_screen.production_units.values.map{|a| complete_units.merge!(a)}
		complete_units = Troop.new(train_screen.total_units) + Troop.new(complete_units)

		train_config = Troop.new(light: 1000, axe: 5000,ram: 100)

		to_train = (train_config - complete_units).remove_negative

		target_buildings = train_screen.release_time.to_a.select{|a| a[1] < train_until }.map(&:first)

		to_train_in_time = Troop.new

		target_buildings.map do |building|
			seconds_to_train = train_until - train_screen.release_time[building]
			building_to_train = to_train.from_building(building)
			building_to_train.to_h.map do |unit,qte|
				train_seconds = train_screen.train_info["axe"]["build_time"]
				binding.pry if (qte > 0)
				while (seconds_to_train > 0 && qte > 0) 
					to_train_in_time[unit] += 1
					seconds_to_train -= train_seconds
					qte -= 1
				end
			end
		end

		

		binding.pry
	end
end

RSpec.describe Task::PillageAround, type: :model do
  it "pillage_test_local" do 
    Task::PillageAround.new.test_local
    # Task::UpdateDailyInformation.new.test_local
    # Task::PlayerMonitor.new.test_local
    # Dummy.new.run
  end

end
