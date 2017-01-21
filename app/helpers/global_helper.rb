module GlobalHelper
  def generate_url args
  	if (!args.include?('village'))
  		return "/game.php?village=#{@vid}&" + args.to_query
  	else
  		return "/game.php?" + args.to_query
  	end
  end
end
