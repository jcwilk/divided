module DV
  class Round < Grape::API
    format :json

    namespace :round do
      route_param :index do
        desc 'Get a round.'
        params do
          requires :index, type: Integer, desc: 'Round index.'
        end

        get do
          round = ::Round.by_index(params[:index])
          if round.nil?
            error! 'Round not found!', 404
          else
            present round, with: DV::Representers::Round
          end
        end
      end
    end
  end
end
