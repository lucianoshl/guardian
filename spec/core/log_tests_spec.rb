require 'rails_helper'

RSpec.describe do

  it "log_test" do
    Rails.logger.debug("debug")
    Rails.logger.info("info")
    Rails.logger.warn("warn")
    Rails.logger.error("error")
    Rails.logger.fatal("fatal")
    Rails.logger.unknown("unknown with log_level=#{Rails.logger.level}")
  end

end
