module DV
  module Representers
    module Room
      include DV::Representers::Base

      property :id

      link :self do |opts|
        build_url(opts,"/dv/rooms/#{id}")
      end

      link 'dv:current_round' do |opts|
        build_url(opts,"/dv/current_round")
      end
    end
  end
end
