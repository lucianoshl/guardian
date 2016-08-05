class Parser::Train < Parser::Basic

  def parse screen
    super
    screen.current_units = {}
    screen.all_units = {}
    @page.search('input').map do |line|
      unit = line.parents(4).search('.imageContainer a').attr('href').text.scan(/unit=(.*?)&/).first.first
      current,total = line.parents(4).search('.imageContainer').text.strip.split('/').map(&:to_i)
      screen.current_units[unit] = current
      screen.all_units[unit] = total
    end
  end

end