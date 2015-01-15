require 'roar/json/hal'

module DV
  module Representers
    module Base
      def self.included(klass)
        klass.instance_eval do
          include Roar::JSON::HAL
          include Grape::Roar::Representer

          curies do |opts|
            [
              name: :dv,
              href: build_url(opts,'/doc/{rel}'), #TODO: Make this point at swagger?
              templated: true
            ]
          end
        end
      end

      private

      def build_url(opts, path)
        URI.parse(base_url(opts)).tap do |uri|
          uri.path = ''
        end.to_s+path
      end

      def base_url(opts)
        if opts[:env].present?
          request = Grape::Request.new(opts[:env])
          request.base_url
        else
          puts "Warning! Unable to get hostname"
          "http://missing.example.com"
        end
      end
    end
  end
end
