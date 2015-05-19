module DV
  module Representers
    class Room < Grape::Roar::Decorator
      include DV::Representers::Base

      property :id

      link :self do |opts|
        build_url(opts,"/dv/rooms/#{id}")
      end

      link 'dv:current_round' do |opts|
        build_url(opts,"/dv/current_round") #TODO: room specific
      end

      link 'dv:join' do |opts|
        build_url(opts,"/dv/join") #TODO: room specific
      end
    end
  end
end
