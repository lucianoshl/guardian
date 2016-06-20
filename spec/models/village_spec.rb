require 'rails_helper'

RSpec.describe Village, type: :model do
  it "test_pillage_candidates" do
    Village.pillage_candidates
  end
  it "Village.predict_production" do
    Report.not_in(target_buildings: [nil]).first.target.predict_production(100)
  end
end
