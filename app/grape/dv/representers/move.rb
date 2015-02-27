module DV
  module Representers
    class Move < Grape::Roar::Decorator
      include DV::Representers::Base

      property :x
      property :y
      property :action

      link :self do |opts|
        build_url(opts,"/dv/round/#{round_id}/participant/#{player_uuid}/move/#{id}")
      end
    end
  end
end
