class Screen::UserRegister < Screen::Anonymous

  attr_accessor :form

  base 'https://www.tribalwars.com.br'
  endpoint '/register.php'

  def register(user)
    form['name'] = user.name
    form['password'] = user.password
    form['password_confirm'] = user.password
    form['email'] = user.email
    form['agb'] = 'on'
    result = form.submit
    if (result.search('.error').size > 0)
      throw Exception.new()
    end
  end

end