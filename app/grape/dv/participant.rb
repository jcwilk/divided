module DV
  class Participant < Grape::API
    format :json

    namespace :participant do
      route_param :id do
        desc 'Get one room.'
        params do
          requires :id, type: String, desc: 'Player uuid.'
        end

        get do
          #TODO: make this specific to a round
          # will require returning the current round and next round
          # in the round advancement event to the client
          # since the next round will have all the next moves
          player = ::Player.alive_by_uuid(params[:id])
          if player.nil?
            error! 'Participant not found!', 404
          else
            present player, with: DV::Representers::Participant
          end
        end
      end
    end
  end
end
