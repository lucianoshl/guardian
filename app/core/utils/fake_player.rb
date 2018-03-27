class Utils::FakePlayer < User
  def initialize
    binding.pry
    # self.name = I18n.transliterate(Mechanize.new.get("http://www.behindthename.com/random/random.php?number=2&gender=f&surname=&all=yes").search('.heavyhuge').text.strip).split(' ').join(' ')
    # self.password = user.name.parameterize + "-12345"
    # self.email = "#{user.name.parameterize}@invitect-company.com"
    # self.world = ENV['TW_WORLD']
  end
end