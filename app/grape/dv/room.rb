module DV
  class Room < Grape::API
    format :json

    namespace :room do
      route_param :id do
        desc 'Get one room.'
        params do
          requires :id, type: String, desc: 'Player uuid.'
        end

        get do
          room = ::Room.by_uuid(params[:id])
          if room.nil?
            render nothing: true, status: 404
          else
            present room, with: DV::Representers::Room
          end
        end
      end
    end
  end
end
