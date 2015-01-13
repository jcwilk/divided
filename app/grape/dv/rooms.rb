module DV
  class Rooms < Grape::API
    format :json

    namespace :rooms do
      desc 'Get all the rooms.'
      get do
        present ::Room.all, with: DV::Representers::Rooms
      end
    end
  end
end
