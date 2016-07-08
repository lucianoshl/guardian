class GuardianDeploy
  include Mongoid::Document

  field :version, type: String
  field :commit, type: String
  field :date, type: DateTime
  # field :read, type: Boolean, default: false

  def self.get_current_version
    app = 'guardian-luciano'    
    key = 'ae3660ebf6526ebf756ab32ab5d558b77b847415'    
    heroku  = Heroku::API.new(:api_key => key)

    release = heroku.get_releases(app).body.last
    result = GuardianDeploy.new
    result.version = release["name"]
    result.commit = release["commit"]
    result.date = release["created_at"].to_time
    result
  end

  def self.current
    GuardianDeploy.last
  end

  def self.refresh_version
    last_version = GuardianDeploy.asc(:date).last
    current = GuardianDeploy.get_current_version
    if (last_version.nil? || last_version.version != current.version)
      current.save
    end
  end


end
