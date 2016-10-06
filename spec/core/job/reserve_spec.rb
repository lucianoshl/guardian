require 'rails_helper'

RSpec.describe Job::Reserve , type: :model do

  it "create_with_coordinate" do    
  	job = Job::Reserve.new('399|418')
  	expect(job.x).to equal(399)
  	expect(job.y).to equal(418)

  	job = Job::Reserve.new(399,418)
  	expect(job.x).to equal(399)
  	expect(job.y).to equal(418)

    job = Job::Reserve.new(Village.new(x:399,y:418))
    expect(job.x).to equal(399)
    expect(job.y).to equal(418)

    job = Job::Reserve.new(18239)
    expect(job.x).to equal(399)
    expect(job.y).to equal(418)


    job = Job::Reserve.new(Village.where(vid: 18239).first.id)
    expect(job.x).to equal(399)
    expect(job.y).to equal(418)
  end

  it "execute_reserve" do
    job = Job::Reserve.new('399|418').run
  end

end
