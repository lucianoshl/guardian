require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Guardian
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    Delayed::Worker.default_queue_name = "normal_priority"
    Delayed::Worker.queue_attributes = { 
      high_priority: { priority: -10 },
      normal_priority: { priority: 0 },
      low_priority: { priority: 10 }
    }

    config.i18n.available_locales = ['pt-BR','en']
    config.i18n.default_locale = 'pt-BR'
    config.time_zone = Time.zone = 'Brasilia'

    if (['development','test'].include?(Rails.env)) 
        Thread.new do 
            FileWatcher.new(Dir.glob("#{Rails.root}/**/*.rb")).watch do |f| 
                load(f)
            end
        end
    end

    Mongoid.logger.level = Logger::INFO

    ENV['RAILS_ADMIN_THEME'] = 'material_theme'
  end
end
