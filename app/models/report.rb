class Report
  include Mongoid::Document
  include Mongoid::Enum

  field :erase_url, type: String
  enum :status, [:win, :lost, :win_lost]
  belongs_to :origin, class_name: Village.to_s
  belongs_to :target, class_name: Village.to_s
  field :occurrence, type: DateTime
  field :luck, type: Float
  field :moral, type: Float

  field :origin_troops, type: Hash
  field :origin_troops_losses, type: Hash

  field :target_troops, type: Hash
  field :target_troops_losses, type: Hash

  embeds_one :pillage, as: :resourcesable
  embeds_one :resources, as: :resourcesable

end