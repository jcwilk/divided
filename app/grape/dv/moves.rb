module DV
  class Moves < Grape::API
    format :json

    desc 'Get all the moves for a participant.'
    params do
      requires :id, type: String, desc: 'Participant uuid.'
    end
    get '/participant/:id/moves' do
      participant = Player.alive_by_uuid(params[:id])
      if participant.present?
        present participant.moves, with: DV::Representers::Moves
      else
        render nothing: true, status: 404
      end
    end
  end
end
