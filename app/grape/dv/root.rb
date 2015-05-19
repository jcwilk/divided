module DV
  class Root < Grape::API
    format :json
    formatter :json, Grape::Formatter::Roar

    desc 'The API root.'
    params do
    end
    get do
      present self, with: DV::Representers::Root
    end

    mount DV::CurrentRound
    mount DV::Move
    mount DV::Moves
    mount DV::Participant
    mount DV::Room
    mount DV::Rooms
    mount DV::Round
    mount DV::Join

    add_swagger_documentation api_version: 'v1'
  end
end
