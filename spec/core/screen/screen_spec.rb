require 'rails_helper'

RSpec.describe Screen::ReportView, type: :model do

  before(:all) do
    Cookie.all.delete
    @params = {vilage: Village.my.first.vid}
  end

  it "Main" do
    Screen::Main.new( @params )
  end

  it "Place" do
    Screen::Place.new( @params )
  end

  it "ReportList" do
    Screen::ReportList.new(mode: 'attack')
  end

  it "ReportView" do
    Screen::ReportView.new(view: 16750852)
  end

  it "Simulator" do
    Screen::Simulator.new( @params )
  end

  it "StatsOwn" do
    Screen::StatsOwn.new( @params )
  end

end
