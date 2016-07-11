class RenewVillageReserve
  def run
    page = Screen::Reservations.new(group_id:'creator_id',filter:User.current.player.pid)

    page.reserves.map do |reserve|
      page.cancel_reserve(reserve)
      page.do_reserve(reserve.village)
    end
  end
end