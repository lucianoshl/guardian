Dir["#{Rails.root}/app/core/task/*.rb"].map{|f| ActiveSupport::Dependencies.load_file f }

Task.constants.map do |const|
  task = Task.const_get(const)
  task.init_schedules if (task.respond_to?('init_schedules'))
end


Dir["#{Rails.root}/app/models/job/*.rb"].map{|f| ActiveSupport::Dependencies.load_file f }

Job.constants.map do |const|
  task = Job.const_get(const)
  task.init_schedules if (task.respond_to?('init_schedules'))
end
