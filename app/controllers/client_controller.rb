class ClientController < ApplicationController
  def new
    @slider_vars = {
      animationDuration: 650,
      blinkDelay: 300
    }
    player = Player.alive_by_uuid(session[:player_uuid]) || Player.new_active
    session[:player_uuid] = player.uuid
    @player_uuid = player.uuid

    @room = DV::Representers::Room.render(
      Room.all.first
    )
  end
end
