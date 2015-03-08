module DV
  class Moves < Grape::API
    format :json

    desc 'Get all the moves for a participant.'
    params do
      requires :id, type: String, desc: 'Participant uuid.'
    end
    get '/participant/:id/moves' do
      #TODO: make this specific to a round
      #if round.index == params[:round_id]
        player = ::Player.alive_by_uuid(params[:id])
      #end

      if player
        round = ::Room.all.first.current_round
        participant = ::Participant.new(player: player, round: round)
        present participant.moves, with: DV::Representers::Moves
      else
        error! 'Participant not found!', 404
      end
    end
  end
end
