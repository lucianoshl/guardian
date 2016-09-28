class Village
  include Mongoid::Document
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

  field :use_in_pillage, type: Boolean, default: true
  field :in_blacklist, type: Boolean, default: false

  has_many :reports , inverse_of: 'target' 

  embeds_one :reserved_troops, class_name: Troop.to_s

  accepts_nested_attributes_for :reserved_troops
  

  belongs_to :player

  scope :my, -> { where(player: User.current.player) }
  scope :targets, -> { not_in(player: [User.current.player]) }
  scope :monitor, -> { targets.in(state: ["trops_without_spy","strong","has_troops"]) }
  scope :blacklist, -> { targets.where(in_blacklist: true) }

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
    threshold = User.current.player.points * 0.6


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

    # blacklist = ['jukita650']

    # Player.in(name: blacklist).to_a.map do |player|
    #   player.villages.map do |black_village|
    #     black_village.next_event = nil
    #     black_village.state = :ally
    #     black_village.save
    #   end
    # end

    result = lte(points:threshold).not_in(state: [:ally,:strong])
    Rails.logger.info("Searching pillage_candidates: end")
    result
  end
  
  def self.clean_all_states
    Village.all.map(&:clean_state)
  end

  def inative_players
    monitor.map{|a| [a,a.points_history.last] }.select{|a| a[1]["date"] <= Time.zone.now - 3.day }.map{|a| a[0]}
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

end
