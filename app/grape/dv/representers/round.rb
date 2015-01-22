module DV
  module Representers
    class Round < Grape::Roar::Decorator
      include DV::Representers::Base

      property :index

      link :self do |opts|
        build_url(opts,"/dv/round/#{index}")
      end

      collection :participants, extend: DV::Representers::Participant, as: :participants, embedded: true
    end
  end
end
