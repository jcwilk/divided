module DV
  module Representers
    class Move < Grape::Roar::Decorator
      include DV::Representers::Base

      property :x
      property :y

      link :self do |opts|
        build_url(opts,"/dv/participant/#{player_uuid}/moves/#{id}")
      end
    end
  end
end
