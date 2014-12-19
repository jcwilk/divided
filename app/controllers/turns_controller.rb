class TurnsController < ApplicationController
  def create
    #TODO: more strict round control (help, test me)
    #if params[:current_round].present? && params[:current_round].to_i == Round.current_number
    player = Player.alive_by_uuid(params[:player_uuid])
    if player.nil?
      render nothing: true, status: 403
    elsif Round.add_move(player,params[:next_pos].map(&:to_i))
      head :ok, content_type: 'text/html'
    else
      render nothing: true, status: 422
    end
  end
end
