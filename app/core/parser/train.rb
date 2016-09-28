class Parser::Train < Parser::Basic

  def parse screen
    super
    screen.current_units = {}
    screen.all_units = {}
    screen.build_info = {}
    @page.search('#train_form > .mobileBlock').map do |element|
      unit = element.search('input').attr('name').value
      current,total = element.search('.imageContainer').text.strip.split('/').map(&:to_i)
      screen.current_units[unit] = current
      screen.all_units[unit] = total
    end
  end

end