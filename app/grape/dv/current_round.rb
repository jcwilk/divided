module DV
  class CurrentRound < Grape::API
    format :json

    namespace :current_round do
      desc 'Get current round.'
      get do
        round = ::Round.current_round
        if round.nil?
          render nothing: true, status: 404
        else
          present round, with: DV::Representers::Round
        end
      end
    end
  end
end
