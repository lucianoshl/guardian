require 'rails_helper'

RSpec.describe Mobile::ReportList, type: :model do
  it "load_all_reports" do
    Mobile::ReportList.load_all
  end
end
