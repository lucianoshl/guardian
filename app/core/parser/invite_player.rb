class Parser::InvitePlayer < Parser::Basic

  def parse(screen)
    super
    screen.form = @page.form
    # screen.invite_url = @page.search('#ref_link_input').attr('value').value
    screen.invite_url = "https://www.tribalwars.com.br/register.php?ref_code=BR677Y57&ref=player_invite_linkrl"
    # binding.pry
  end

end