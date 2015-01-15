module DV
  module Representers
    module Participant
      include DV::Representers::Base

      property :uuid

      link :self do |opts|
        build_url(opts,"/dv/participant/#{uuid}")
      end

      link 'dv:moves' do |opts|
        build_url(opts,"/dv/participant/#{uuid}/moves")
      end
    end
  end
end
