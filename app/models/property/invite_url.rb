class Property::InviteUrl < Property::Simple
  field :user, type: String
  field :limit_exceeded, type: Date

  before_create do 
    self.user = Mechanize.new.get(self.content).search('.register').first.parent.search('p').text.scan(/jogador (.+) para/).first.first
  end
end