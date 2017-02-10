class Village
  include Mongoid::Document
  include RailsAdminCharts

  field :vid, type: Integer
  field :x, type: Integer
  field :y, type: Integer

  field :limit_partner, type: Integer

  field :name, type: String
  field :points, type: Integer
  field :points_history, type: Array

  field :state, type: String
  field :next_event, type: DateTime
  field :is_barbarian, type: Boolean
  field :is_sorcerer, type: Boolean

  field :in_blacklist, type: Boolean
  field :use_in_pillage, type: Boolean, default: true
  field :disable_auto_recruit, type: Boolean, default: false
  field :model_id, type: BSON::ObjectId
  field :label, type: String

  has_many :reports , inverse_of: 'target' 

  embeds_one :reserved_troops, class_name: Troop.to_s

  accepts_nested_attributes_for :reserved_troops

  has_many :send_attack, class_name: Job::SendAttack.to_s, inverse_of: 'origin' 

  belongs_to :player

  scope :my, -> { where(player: User.current.player).asc(:label) }
  scope :targets, -> { not_in(player: [User.current.player]) }
  scope :monitor, -> { targets.in(state: Village.threat_status) }

  scope :inative_players, -> do 
    self.in( id: monitor.map{|a| [a,a.points_history.last] }.select{|a| a[1]["date"] <= Time.zone.now - 3.day }.map{|a| a[0]}.map(&:id) )
  end

  scope :with_snob, -> do
    self.in( id: Village.my.select {|v| Screen::Snob.new(village: v.vid).total_snob > 0}.map(&:id) )
  end

  scope :snob_targets, -> do
    snobs = self.with_snob.to_a
    targets = self.monitor.to_a 

    combinations = targets.map do |target|
      dists = (snobs.map do |my_v|
        {
          my_v: my_v,
          distance: my_v.distance(target)
        }
      end).select do |element|
        element[:distance] > 10
      end
      dists.firt
    end

    binding.pry


  end

  index({ x: 1, y: 1 }, { unique: true })
  index({ vid: 1 }, { unique: true })

  def clean_state
      self.state = nil;
      self.next_event = nil
      self.save
  end

  def distance other
    Math.sqrt ((self.x - other.x)**2 + (self.y - other.y)**2)
  end

  def last_report
    reports.desc(:occurrence).first
  end

  def to_s
    return [x,y].join('|')
  end

  def predict_production(resources)
    resources/self.reports.not_in(target_buildings: [nil]).desc(:occurrence).first.hour_production
  end

  def move_to_state state
    self.state = state
    self.next_event = Time.zone.now
    self.save
    Delayed::Job.where(handler: /PillageAround/).first.run_now
  end

  def db_merge
    merged = self.class.where(vid: self.vid).first || Village.new
    attrs = self.attributes.clone
    attrs.delete('_id')
    merged.attributes = attrs
    merged.save
    return merged
  end

  def self.pillage_candidates
    Rails.logger.info("Searching pillage_candidates: start")
    # threshold = User.current.player.points * 0.6
    threshold = 1500


    Rails.logger.info("Reset ally and strong: start")
    self.in(state: [:ally,:strong]).update_all(next_event: nil,state: nil)
    Rails.logger.info("Reset ally and strong: end")

    Rails.logger.info("Update strong players: start")
    strong_villages = Village.in(player_id: Player.gt(points: threshold).pluck(:id) )
    strong_villages.update_all(next_event: nil,state: :strong)
    Rails.logger.info("Update strong players: end")

    Rails.logger.info("Update allies players: start")
    ally = User.current.player.ally
    
    if (!ally.nil?)
      partners_villages = ally.partners.map(&:players).flatten
      ids = partners_villages.concat(ally.players).map(&:villages).flatten.map(&:vid)
      self.in(vid: ids).update_all(next_event: nil,state: :ally)
    end
    Rails.logger.info("Update allies players: end")

    Rails.logger.info("Update blacklist players: start")
    Village.in(player_id: Player.blacklist.pluck(:id)).update_all(next_event: nil,state: :blacklist)
    Rails.logger.info("Update blacklist players: end")

    result = lte(points:threshold).not_in(state: [:ally,:strong,:blacklist])
    Rails.logger.info("Searching pillage_candidates: end")
    result
  end
  
  def self.clean_all_states
    Village.all.map(&:clean_state)
  end

  def increase_limited_by_partner
    self.limit_partner = 0 if (self.limit_partner.nil?)
    self.limit_partner += 1
    self.save
    Rails.logger.info("Increasing limit partner from #{self.limit_partner} to #{self.limit_partner+1}".red.on_white)
  end

  def reset_partner_count
    self.limit_partner = 0
    self.save
  end

  def is_threat?
    Village.threat_status.include?(self.state)
  end

  def self.threat_status
    ["trops_without_spy","strong","has_troops"]
  end

  def self.graph_data since=30.days.ago
    ((self.distinct(:state) - ['far_away']).map do |a|
      total = where(state:a).count
     {name: "#{a.humanize} (#{total})" , y: total }
   end).sort { |a,b| b[:y] <=> a[:y] }
  end

  def self.chart_type
    return 'pie'
  end

  def model_id_enum
    Model::Village.all.map {|model| [model.name,model.id] }
  end

  def model
    return nil if (self.model_id.nil?)

    Model::Village.where(id: self.model_id).first
  end

  def significant_name
      
    local = self.y/100.floor * 10 + self.x/100.floor

    if (self.model.nil?)
      # return self.label || "SEM MODELO"
      result = "SEM MODELO"
    else
      result = self.model.name

      if (!self.label.nil?)
        # result = self.label + '-' + result
        result = result+ '-' + vid.to_s
      end
    end

    return result + " (#{self.x}|#{self.y}) K#{local}"
  end

  def self.my_cache
    Rails.cache.fetch('Village.my', expires_in: 5.minutes) do
      Village.my.to_a
    end
  end

end
