class Report
  include Mongoid::Document
  include Mongoid::Enum

  field :erase_url, type: String
  enum :status, [:win, :lost, :win_lost, :spy, :error, :spy_lost ]
  belongs_to :origin, class_name: Village.to_s
  belongs_to :target, class_name: Village.to_s
  field :occurrence, type: DateTime
  field :luck, type: Float
  field :moral, type: Float

  field :origin_troops, type: Hash
  field :origin_troops_losses, type: Hash

  field :target_troops, type: Hash
  field :target_troops_losses, type: Hash
  
  field :target_buildings, type: Hash

  field :full_pillage, type: Boolean

  field :read, type: Boolean, default: false

  embeds_one :pillage, as: :resourcesable, class_name: Resource.to_s
  embeds_one :resources, as: :resourcesable, class_name: Resource.to_s



  scope :important,->(){not_in(_status: [:win,:spy]).where(read: false).desc(:occurrence)}

  def erase screen
    screen.request(self.erase_url)
  end

  def has_troops?
    (Troop.new(target_troops) - Troop.new(target_troops_losses)).total  > 0
  end

end