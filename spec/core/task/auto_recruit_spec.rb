require 'rails_helper'

RSpec.describe Task::AutoRecruit, type: :model do
  it "test_recruit" do 
  	stub_villages = [
  		Village.where(x:396,y:414).first,

  	]
  	Village.stub(:my) { stub_villages }
    Task::AutoRecruit.new.run
  end

  it "do_task" do 
    # Job::SendAttack.find('58a2949fe6335c0a3789b6e9').execute
    # Job::Reserve.new(targets: 'Fazenda Dois Ipês' ).execute

    # Job::SendAttack.first.execute
    # Job::SnobTarget.new.(coodinate: coordinate).execute

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



end
