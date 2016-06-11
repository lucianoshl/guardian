require 'rails_helper'

RSpec.describe Screen::ReportView, type: :model do
  it "do_login" do
    report = Screen::ReportView.new(view: 13164518).report
    puts report.has_troops?
  end
end
