require 'rails_helper'

RSpec.describe Report, type: :model do
  it "rams_to_destroy_wall" do
    report = Report.gt("target_buildings.wall" => 0 ).first
    if (!report.nil?)
      report.rams_to_destroy_wall
    end
  end

  it "pillage_statistics" do
    Report.pillage_statistics
  end

  # it "load_report" do
  #   Mobile::ReportList.new('attack',0,0,2000).reports
  #   report_s = Mobile::ReportView.new(id: 3566482)
  # end


end
