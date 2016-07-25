require 'rails_helper'

RSpec.describe Village, type: :model do
  it "test_pillage_candidates" do
    Village.pillage_candidates
  end
  it "Village.predict_production" do
    # report = Report.not_in(target_buildings: [nil], target:[nil]).first
    # if (report != nil)
    #   report.target.predict_production(100)
    # end
  end
end
