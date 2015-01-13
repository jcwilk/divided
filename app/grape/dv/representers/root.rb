module DV
  module Representers
    module Root
      include DV::Representers::Base

      link :self do |opts|
        build_url(opts,'/dv')
      end

      link 'sc:turns' do |opts|
        build_url(opts,'/dv/turns')
      end

      link :swagger_doc do |opts|
        build_url(opts,'/dv/swagger_doc')
      end
    end
  end
end
