module DV
  module Representers
    class Rooms < Grape::Roar::Decorator
      include DV::Representers::Base

      collection :to_a, extend: Representers::Room, as: :rooms, embedded: true
    end
  end
end
