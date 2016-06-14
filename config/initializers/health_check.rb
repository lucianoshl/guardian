HealthCheck.setup do |config|

  config.add_custom_check do
    Delayed::Job.where(:last_error.nin => [nil]).count != 0 ? "" : nil
  end

end