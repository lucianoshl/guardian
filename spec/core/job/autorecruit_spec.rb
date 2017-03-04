require 'rails_helper'

RSpec.describe Task::AutoRecruit, type: :model do
  it "test_recruit" do 
  	stub_villages = [
  		Village.where('396|427'.to_coordinate).first, 

  	]
  	Village.stub(:my) { stub_villages }
    Task::AutoRecruit.new.run
  end

  it "do_task" do 
    # Job::SendAttack.find('58a2949fe6335c0a3789b6e9').execute
    # Job::Reserve.new(targets: 'Fazenda Dois Ipês' ).execute

    # Job::SendAttack.first.execute
    Job::SnobTarget.new(coordinate: '380|443').execute
    
    # Job::SnobTarget.new(coordinate: '377|444').execute

    # snobs = 0
    # spears = 0
    # swords = 0
    # heavy = 0


    # Village.my.map do |village|
    #     train = Screen::Train.new(village: village.vid)
    #     snob = Screen::Snob.new(village: village.vid)

    #     spears += train.total_units.spear
    #     swords += train.total_units.sword
    #     heavy += train.total_units.heavy
    #     snobs += snob.total_snob if (snob.enabled)
    # end


    # binding.pry
  	
  end

  it "playground2" do
    targets = %{
    [0011] - TRETA (435|487) K44  --- 
    [0071] - TRETA (439|481) K44  --- 
    [0002] - TRETA (434|478) K44  --- 
    [0065] - TRETA (429|474) K44  --- 
    [0044] - TRETA (426|473) K44  --- 
    [0001] - TRETA (432|473) K44  --- 
    [0043] - TRETA (436|473) K44  --- 
    [0052] - TRETA (436|470) K44  --- 
    [0054] - TRETA (436|469) K44  --- 
    [0051] - TRETA (435|470) K44  --- 
    [0070] - TRETA (434|470) K44  --- 
    [0072] - TRETA (432|471) K44  --- 
    [0076] - TRETA (431|471) K44  --- 
    [0045] - TRETA (431|470) K44  --- 
    [0047] - TRETA (432|470) K44  --- 
    [0049] - TRETA (432|469) K44  --- 
    [0074] - TRETA (432|468) K44  --- 
    [0042] - TRETA (428|469) K44  --- 
    [0006] - TRETA (432|464) K44  --- 
    [0005] - TRETA (433|464) K44  --- 
    [0093] - TRETA (415|451) K44  --- 
    [0069] - TRETA (415|441) K44  --- 
    [0040] - TRETA (434|458) K44  --- 
    [0007] - TRETA (432|460) K44  --- 
    [0035] - TRETA (428|465) K44  --- 
    [0027] - TRETA (424|464) K44  --- 
    }
    targets = targets.scan(/\d{3}\|\d{3}/).flatten.map{|a| a.to_coordinate }

    my_villages = Village.my.to_a

    targets = targets.map do |target|
      r = OpenStruct.new
      r.origin = my_villages.sort {|a,b| a.distance(target) <=> b.distance(target) }.first
      r.target = target
      r.distance = r.origin.distance(target)
      r
    end

    targets = targets.sort{|a,b| a.distance <=> b.distance}
    binding.pry


  end



end
