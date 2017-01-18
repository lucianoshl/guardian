module GlobalHelper
  def generate_url args
  	
  	return "/game.php?village=#{@vid}&" + args.to_query
  end
end
