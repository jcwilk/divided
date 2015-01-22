module DV
  class Move < Grape::API
    format :json

    namespace :participant do
      route_param :participant_id do
        namespace :move do
          route_param :id do
            desc 'Get all the moves for a participant.'
            params do
              requires :participant_id, type: String, desc: 'Participant uuid.'
              requires :id, type: Integer, desc: 'Move id.'
            end
            post do
              raise 'implement me!'
              participant = Participant.from_uuid(params[:id])
              present participant.moves, with: DV::Representers::Moves
            end
          end
        end
      end
    end
  end
end
