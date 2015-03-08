module DV
  class Move < Grape::API
    format :json

    desc 'Get all the moves for a participant.'
    params do
      requires :participant_id, type: String, desc: 'Participant uuid.'
      requires :id, type: Integer, desc: 'Move id.'
      requires :round_id, type: Integer, desc: 'Round id.'
    end
    post '/round/:round_id/participant/:participant_id/move/:id' do
      round = ::Room.all.first.current_round
      if round.index == params[:round_id]
        player = ::Player.alive_by_uuid(params[:participant_id])
      end
      if player
        participant = ::Participant.new(player: player, round: round)
      end

      #TODO: a lot of this is redundant with DV::Moves
      if participant.present?
        move = participant.choose_move(params[:id])

        if move.present?
          present move, with: DV::Representers::Move
        else
          #TODO: better error codes so client can distinguish, see js
          error! 'Unknown move id for participant!', 404
        end
      else
        error! 'Participant not found!', 404
      end
    end
  end
end
