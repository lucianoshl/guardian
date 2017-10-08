source 'https://rubygems.org'

#ruby ENV['CUSTOM_RUBY_VERSION'] || '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-turbolinks'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', git: 'https://github.com/turbolinks/turbolinks-classic.git'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# group :test do
gem "rspec-rails"
# end

group :development do
  gem 'puma'
end

group :production do
  gem 'rails_12factor'
  gem 'daemons'
  gem 'unicorn'
  #gem 'mongoid_store'#, git: 'https://github.com/lucianoshl/mongoid_store.git' 
  gem 'rails_real_favicon'
  gem 'heroku-deflater'  
  gem 'foreman'
end

group :development, :test do
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'byebug'
  gem 'quiet_assets'
  gem 'spring'
end

gem "health_check"
gem 'rails_admin'
gem 'mechanize'
gem 'mongoid'
gem 'delayed_job_mongoid'
gem 'adminlte2-rails'
gem 'active_attr'
gem "mongoid-enum"
gem "parallel"
gem 'chartjs-ror'
gem 'color-generator'
gem 'colorize'
gem 'watir-webdriver'
gem 'selenium-webdriver'
gem 'nprogress-rails'
gem 'dalli'
gem 'socket.io-client-simple'
gem 'heroku-api' 
gem 'filewatcher'
gem 'rails-i18n', '~> 4.0.0'
gem 'washbullet'

gem 'rails_admin_material_theme', '~> 0.2.0'
gem 'rails_admin_charts'
gem 'kaminari-mongoid'

gem 'ruby-progressbar'
gem 'rails_admin_toggleable'

gem 'json', '1.8.6'

# https://github.com/middleman/middleman/issues/1097
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
