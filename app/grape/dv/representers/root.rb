module DV
  module Representers
    class Root < Grape::Roar::Decorator
      include DV::Representers::Base

      link :self do |opts|
        build_url(opts,'/dv')
      end

      link 'dv:rooms' do |opts|
        build_url(opts,'/dv/rooms')
      end

      link :swagger_doc do |opts|
        build_url(opts,'/dv/swagger_doc')
      end
    end
  end
end
