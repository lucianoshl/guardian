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
    Job::SendAttack.find('58a2949fe6335c0a3789b6e9').execute

  	
  end



end
