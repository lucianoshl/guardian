module Guardian
    class << self; 
        attr_accessor :migration_file,:migration_hash,:mongo_url,:current_migration
        @user = nil
        def user
            if (@user.nil?)
                binding.pry
                @user = User.first
            end
            return @user
        end
    end
    
    Guardian.migration_file = Dir["#{Rails.root}/**/guardian.rake"].first
    migration_file_contents = File.read(Guardian.migration_file)
    Guardian.migration_hash = Digest::MD5.hexdigest(migration_file_contents)
    Guardian.current_migration = 'none'
    Guardian.mongo_url = ENV['MONGO_URL']
    if !Guardian.mongo_url.blank?
        Guardian.current_migration = Rails.cache.fetch('current_migration') do 
            Rails.logger.info('Guardian.current_migration not in cache')
            Guardian.current_migration = Property::KeyValue.current_migration('none')
        end
    end
    Rails.logger.info("Guardian.current_migration = #{Guardian.current_migration}")
end