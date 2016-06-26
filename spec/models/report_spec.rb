require 'rails_helper'

RSpec.describe Report, type: :model do
  it "rams_to_destroy_wall" do
    report = Report.gt("target_buildings.wall" => 0 ).first
    report.rams_to_destroy_wall
  end

  it "pillage_statistics" do
    Report.pillage_statistics
  end


end
