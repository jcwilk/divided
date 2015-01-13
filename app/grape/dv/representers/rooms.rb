module DV
  module Representers
    module Rooms
      include DV::Representers::Base

      collection :to_a, extend: Representers::Room, as: :rooms, embedded: true
    end
  end
end
