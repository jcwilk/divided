class ClientController < ApplicationController
  def new
    @slider_vars = {
      #turnDuration: 5000,
      preventDoubleInputDelay: 180,
      waitAfterInputBeforeTurnEndDelay: 200,
      animationDuration: 100
    }
    @player_uuid = SecureRandom.urlsafe_base64(8)
    Round.add_move(@player_uuid)
    #@last_round = Round.last_round.currend_data.to_json
    @first_move = Round.current_data[:players][@player_uuid].to_json
  end
end
