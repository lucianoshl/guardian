class Screen::InvitePlayer < Screen::Basic

  attr_accessor :form,:invite_url

  url screen: 'settings' , mode: 'ref', source: 'map'

  def invite(user)
    form['email'] = user.email
    parse(form.submit)
  end

end
