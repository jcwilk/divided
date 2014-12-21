module DV
  class Turns < Grape::API
    format :json

    namespace :turns do
      # desc 'Get all the turns.'
      # params do
      #   optional :page, type: Integer, default: 1, desc: 'Page to return.'
      # end
      # get do
      #   present Course.order('created_at').page(params[:page]), with: SC::Representers::Courses
      # end

      desc 'Submit your turn.'
      params do
        requires :player_uuid, type: String, desc: 'Player uuid.'
        requires :next_pos, type: Array, desc: 'Chosen move.'
      end
      post do
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
  end
end
