require 'rails_helper'

RSpec.describe Village, type: :model do
  it "test_pillage_candidates" do
    Village.pillage_candidates
  end
  it "barbarian_conquest" do

    villlages = Village.includes(:reports).where(player_id: nil).to_a

    test = villlages.map do |village|
        total_pillage = Resource.new
        village.reports.each do |report|
            total_pillage += report.pillage if (!report.pillage.nil?)
        end
        [village.vid,total_pillage.total]
    end

    village_map = villlages.map{|a| [a.vid,a]}.to_h

    test_sorted = test.sort{|a,b| a[1] <=> b[1]}

    center = Village.where(vid: test_sorted.last.first).first

    candidates = test.select{|a| a.last < 10000}


    candidates = candidates.map {|a| a[2] = village_map[a.first].distance(center); a }


    candidates = candidates.sort {|a,b| a[2] <=> b[2] }

    binding.pry

  end
end
