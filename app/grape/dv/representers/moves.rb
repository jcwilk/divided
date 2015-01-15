module DV
  module Representers
    module Moves
      include DV::Representers::Base

      collection :to_a, extend: Representers::Move, as: :moves, embedded: true
    end
  end
end
