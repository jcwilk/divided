module DV
  class Move < Grape::API
    format :json

    desc 'Get all the moves for a participant.'
    params do
      requires :participant_id, type: String, desc: 'Participant uuid.'
      requires :id, type: Integer, desc: 'Move id.'
    end
    post '/participant/:participant_id/move/:id' do
      player = Player.alive_by_uuid(params[:participant_id])
      if player
        participant = ::Participant.from_player(player: player)
      end

      #TODO: a lot of this is redundant with DV::Moves
      # plus it's too much domain logic for the controller anyways
      if participant.present?
        move = participant.current_moves.find {|m| m.id == params[:id] }

        if move.present?
          ::Round.add_move(player,[move.x,move.y])
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
