require 'rails_helper'

RSpec.describe Screen, type: :model do

  before(:all) do
    # Cookie.all.delete
    @params = {vilage: Village.my.first.vid}
  end

  it "Main" do
    Screen::Main.new( @params )
  end

  it "Place" do
    place = Screen::Place.new( @params )
    # target = Village.all.to_a[2]
    # origin = Village.my.first
    # place.send_attack(origin,target,Troop.new(spy: 5))
  end

  it "ReportList" do
    Screen::ReportList.new(mode: 'attack')
  end

  it "ReportView" do
    # report_s = Screen::ReportView.new(view: 26523729)
    # puts report_s.report.wall_destroyed
    # report_s.report.has_troops?
  end

  it "Simulator" do
    Rails.cache.clear
    Screen::Simulator.new( @params )

    expect(Troop.new(axe: 1).win?(100,0,false)).to equal(false)
  end

  it "StatsOwn" do
    Screen::StatsOwn.new( @params )
  end

  it "AllyContracts" do
    screen = Screen::AllyContracts.new( @params )
    expect(screen.allies.size >= 0).to be_truthy
  end

end
