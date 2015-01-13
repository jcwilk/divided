module DV
  module Representers
    module Turn
      include DV::Representers::Base

      property :id

      link :self do |opts|
        build_url(opts,"/dv/turns/#{id}")
      end

      link 'dv:root' do |opts|
        build_url(opts,'/dv')
      end
    end
  end
end
