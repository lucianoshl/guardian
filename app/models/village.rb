class Village
  include Mongoid::Document
  field :vid, type: Integer
  field :x, type: Integer
  field :y, type: Integer

  field :name, type: String
  field :points, type: Integer
  field :points_history, type: Array

  field :state, type: String
  field :next_event, type: DateTime
  field :is_barbarian, type: Boolean

  has_many :reports , inverse_of: 'target' 

  belongs_to :player
  
  def self.clean_all_states
    Village.all.map do |v| 
      v.state = nil;
      v.next_event = nil
      v.save
    end
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

  def self.pillage_candidates
    threshold = User.first.player.points * 0.6

    self.in(state: [:ally,:strong]).update_all(next_event: nil,state: nil)

    gt(points: threshold).update_all(next_event: nil,state: :strong)

    ally = User.first.player.ally
    
    if (!ally.nil?)
      ids = ally.players.map(&:villages).flatten.map(&:vid)
      self.in(vid: ids).update_all(next_event: nil,state: :ally)
    end

    lte(points:threshold).not_in(state: [:ally,:strong])
  end

  def self.my
    where(player: User.first.player)
  end

end
