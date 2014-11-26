class TurnsController < ApplicationController
  def create
    #TODO: more strict round control (help, test me)
    #if params[:current_round].present? && params[:current_round].to_i == Round.current_number
      Round.add_move(params[:player_uuid],params[:next_pos].map(&:to_i))
    #end

    #TODO: conditionally confirm to the client so it can give feedback to
    # the player that the directive has been queued
    head :ok, content_type: 'text/html'
  end
end
