require 'rails_helper'

RSpec.describe do
  it "do_login" do  
    b = Watir::Browser.new :phantomjs
    b.goto 'http://example.com/'

    binding.pry

    puts b.text.include? "Example Domain"
  end
end