class Screen::Buddies < Screen::Basic

  attr_accessor :requests

  url screen: 'buddies'

  def cancel_request(name)
    requests.select{|a| a.name == name}.map do |r|
      request(r.request_url)
    end
  end

end