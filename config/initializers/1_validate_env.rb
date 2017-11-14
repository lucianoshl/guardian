not_migrated_system = Guardian.migration_hash != Guardian.current_migration
running_in_rake = $0.include?('rake')

if (not_migrated_system && !running_in_rake)
    Rails.logger.error(%{
        Please, run 'bundle exec rake guardian:migrate RAILS_ENV=#{Rails.env}
        Saved   hash is #{Guardian.migration_hash}
        Current hash is #{Guardian.current_migration}')
    exit
end