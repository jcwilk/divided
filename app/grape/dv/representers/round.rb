module DV
  module Representers
    module Round
      include DV::Representers::Base

      property :index

      link :self do |opts|
        build_url(opts,"/dv/round/#{index}")
      end

      link 'dv:root' do |opts|
        build_url(opts,'/dv')
      end
    end
  end
end
