namespace :guardian do
  desc "Populate database with metadata"
  task migrate: :environment do
    Rails.cache.delete('current_migration')
    current_migration = Property::KeyValue.current_migration
    if (current_migration.content == Guardian.migration_hash)
      Rails.logger.info('Migration hash not changed')
    else
      Rails.logger.info('Migration hash change... running migrations')
      main_user = User.where(main:true).first
      if (main_user.nil?)
        main_user = User.new({
          world: ENV['TW_WORLD'],
          name: ENV['TW_USER'],
          password: ENV['TW_PASS'],
          main: true
        })
        main_user.save
      end
      user_pid = Screen::Guest.new(name:ENV['TW_USER']).result_list.first[:pid]
      main_user.save
      Screen::UnitData.new.units.map(&:save)
      Task::PlayerMonitor.new.run
      main_user.player = Player.where(pid: user_pid).first
      raise Exception.new('Invalid main player state') if main_user.player.nil?
      main_user.save
      Metadata::Building.populate

      Dir["#{Rails.root}/app/core/task/*.rb"].map{|f| ActiveSupport::Dependencies.load_file f }

      Task.constants.map do |const|
        task = Task.const_get(const)
        Rails.logger.info("Running init_schedules for #{task}")
        task.init_schedules if (task.respond_to?('init_schedules'))
      end

      Dir["#{Rails.root}/app/models/job/*.rb"].map{|f| ActiveSupport::Dependencies.load_file f }

      Job.constants.map do |const|
        task = Job.const_get(const)
        task.init_schedules if (task.respond_to?('init_schedules'))
      end
      current_migration.content = Guardian.migration_hash
      current_migration.save
    end
    Rails.cache.write('current_migration', Guardian.migration_hash)
  end
end
