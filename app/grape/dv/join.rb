module DV
  class Join < Grape::API
    format :json

    namespace :join do
      desc 'Join the room.' #TODO: currently not specific to a room

      #NB: I dislike that this POST gets its own resource.
      # Ideally it would be a POST on an existing resource that
      # represented the participants for the room. Currently there
      # is only a participants resource for a specific round, and
      # making the join POST be specific to a round doesn't seem
      # appropriate since you wouldn't really want join links to
      # go stale as the round advances... Nor would you want to
      # imply it was possible to join the participants of previous
      # rounds... Nor (thor?) is it even really appropriate since
      # it's actually the next round that you'll be joining

      # Possibly if there were participants of the current_round
      # and not just the round it referred to? Perhaps for a later
      # refactoring if the opportunity presents itself.
      post do
        uuid = headers['uuid'] || headers['Uuid']
        round = ::Round.current_round
        player = Player.alive_by_uuid(uuid)

        if round.nil?
          fail 'Missing round!'
        elsif player.nil?
          error! 'Unknown uuid!', 404
        elsif !round.join(player)
          error! 'Player unable to join!', 400
        else
          present player, with: DV::Representers::Participant
        end
      end
    end
  end
end
