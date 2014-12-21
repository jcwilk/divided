module DV
  module Representers
    module Turn
      include Roar::JSON::HAL
      include Grape::Roar::Representer

      property :id

      curies do |opts|
        [
          name: :dv,
          href: "#{base_url(opts)}/doc/{rel}", #TODO: Make this point at swagger?
          templated: true
        ]
      end

      link :self do |opts|
        "#{base_url(opts)}/dv/turns/#{id}"
      end

      link 'dv:root' do |opts|
        "#{base_url(opts)}/dv"
      end

      private

      def base_url(opts)
        request = Grape::Request.new(opts[:env])
        request.base_url
      end
    end
  end
end
