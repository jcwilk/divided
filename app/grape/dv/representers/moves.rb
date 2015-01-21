module DV
  module Representers
    class Moves < Grape::Roar::Decorator
      include DV::Representers::Base

      collection :to_a, extend: Representers::Move, as: :moves, embedded: true
    end
  end
end
