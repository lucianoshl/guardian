require 'rails_helper'

RSpec.describe type: :model do
  it "do_login" do
    Cookie.all.delete
  end
end
