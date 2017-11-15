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
      main_user.pid = Screen::Guest.new(name:ENV['TW_USER']).result_list.first[:pid]
      main_user.save
      Screen::UnitData.new.units.map(&:save)
      Task::PlayerMonitor.new.run
      main_user.save
      Metadata::Building.populate
      current_migration.content = Guardian.migration_hash
      current_migration.save
    end
    Rails.cache.write('current_migration', Guardian.migration_hash)
  end
end
