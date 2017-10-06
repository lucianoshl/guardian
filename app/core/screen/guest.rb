class Screen::Guest < Screen::Anonymous

  attr_accessor :result_list

  endpoint '/guest.php'
end