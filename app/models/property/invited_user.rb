class Property::InvitedUser < Property::Simple
  field :user, type: String
  field :name, type: String
  field :password, type: String
  field :upgraded, type: Boolean
  field :distance, type: Float
end