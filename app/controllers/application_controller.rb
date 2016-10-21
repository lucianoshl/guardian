class ApplicationController < ActionController::Base

  layout 'responsive'

  before_filter do 
    

    @report_enum =  {
      win: 'https://brs1.tribalwars.com.br/graphic/dots/green.png',
      win_lost: 'https://brs1.tribalwars.com.br/graphic/dots/yellow.png',
      spy: 'https://brs1.tribalwars.com.br/graphic/dots/blue.png',
      spy_lost: 'https://brs1.tribalwars.com.br/graphic/dots/red_blue.png',
      lost: 'https://brs1.tribalwars.com.br/graphic/dots/red.png',
    } 

    @user = User.first
    @avatar_url = @user.avatar_url.nil? ? "crow_45x45.png" : @user.avatar_url

  end



  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
