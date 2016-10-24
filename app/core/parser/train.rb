class Parser::Train < Parser::Basic

  def parse screen
    super
    screen.current_units = {}
    screen.total_units = {}

    @page.search('#train_form > .mobileBlock').map do |element|
      unit = element.search('input').attr('name').value
      current,total = element.search('.imageContainer').text.strip.split('/').map(&:to_i)
      screen.current_units[unit] = current
      screen.total_units[unit] = total
    end

    Unit.names.map do |name|
      screen.current_units[name.to_s] ||= 0
      screen.total_units[name.to_s] ||= 0
    end

    screen.production_units = {}
    screen.release_time = {}

    screen.release_time['barracks'] ||= Time.zone.now
    screen.release_time['stable'] ||= Time.zone.now
    screen.release_time['garage'] ||= Time.zone.now

    @page.search('div[id*=replace]').map do |element|
      building = element.attr('id').gsub('replace_','')
      screen.production_units[building] ||= {}

      element.search('.queueItem').map do |queueItem|
        unit = queueItem.search('img').first.attr('src').scan(/unit_(\w+).png/).first.first
        screen.production_units[building][unit] ||= 0
        screen.production_units[building][unit] += queueItem.search('img').first.parent.text.extract_number
      end

      last_line = element.search('.queueItem').last
      screen.release_time[building] = last_line.search('div:eq(2)').text.strip.split("\n").last.strip.parse_datetime
    end


    screen.train_info = ExecJS.eval(@page.body.scan(/unit_managers.units = ({(?:\n|.)+?);/).first.first)

  end

end