class ApplicationController < ActionController::Base
  layout 'admin_lte_2'

  before_filter do 
    @report_enum =  {
      win: 'https://brs1.tribalwars.com.br/graphic/dots/green.png',
      win_lost: 'https://brs1.tribalwars.com.br/graphic/dots/yellow.png',
      spy: 'https://brs1.tribalwars.com.br/graphic/dots/blue.png',
      lost: 'https://brs1.tribalwars.com.br/graphic/dots/red.png',
    } 
  end



  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
