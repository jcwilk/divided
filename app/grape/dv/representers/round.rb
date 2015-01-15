module DV
  module Representers
    module Round
      include DV::Representers::Base

      property :index

      link :self do |opts|
        build_url(opts,"/dv/round/#{index}")
      end

      collection :participants, extend: DV::Representers::Participant, as: :participants, embedded: true
    end
  end
end
