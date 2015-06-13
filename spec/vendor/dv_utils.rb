module DvUtils
  module Mixin
    def dv_client
      HyperResource.new(
        root: 'http://api.example.com/dv',
        faraday_options: {
          builder: Faraday::RackBuilder.new do |builder|
            builder.request :url_encoded
            builder.adapter :rack, app
          end
        }
      )
    end

    def first_room
      dv_client.dv_rooms.first
    end

    def current_round
      first_room.dv_current_round
    end

    def available_moves(uuid)
      p = get_participant_by_uuid(uuid)
      fail "Participant not found!" if p.nil?
      p.moves.to_a
    end

    def get_participant_by_uuid(uuid)
      current_round.participants.find {|p| p.uuid == uuid }
    end

    def finish_after_round(&block)
      finish_in(Round::ROUND_DURATION+1,&block)
    end
  end
end
