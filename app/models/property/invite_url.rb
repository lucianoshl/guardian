class Property::InviteUrl < Property::Simple
  field :user, type: String
  field :limit_exceeded, type: Date
end