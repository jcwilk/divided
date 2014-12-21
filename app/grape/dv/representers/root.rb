#TODO: extract to Base module/class

require 'roar/json/hal'

module DV
  module Representers
    module Root
      include Roar::JSON::HAL
      include Grape::Roar::Representer

      curies do |opts|
        [
          name: :dv,
          href: "#{base_url(opts)}/doc/{rel}", #TODO: Make this point at swagger?
          templated: true
        ]
      end

      link :self do |opts|
        "#{base_url(opts)}/dv"
      end

      link 'sc:turns' do |opts|
        "#{base_url(opts)}/dv/turns"
      end

      link :swagger_doc do |opts|
        "#{base_url(opts)}/dv/swagger_doc"
      end

      private

      def base_url(opts)
        request = Grape::Request.new(opts[:env])
        request.base_url
      end
    end
  end
end
