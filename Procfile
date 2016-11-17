web: bundle exec unicorn -p $PORT -E $RACK_ENV -c ./config/unicorn.rb
worker: RAILS_ENV=production bin/delayed_job --pool=* start