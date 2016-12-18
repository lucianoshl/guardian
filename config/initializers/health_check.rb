HealthCheck.setup do |config|

  config.add_custom_check do
    job_without_error = Delayed::Job.where(:last_error.nin => [nil]).count == 0


    locked_jobs = Delayed::Job.where(:locked_by.nin => [nil]).to_a

    locked_delayed = locked_jobs.select{|a| (Time.zone.now - a.locked_at) > 20.minutes }

    locked_delayed.map {|a| a.locked_at = nil; a.locked_by = nil; a.save }

    job_without_error ? "" : nil
  end

end