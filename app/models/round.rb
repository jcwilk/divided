module Round
  ROUND_DURATION = 5 #seconds

  class << self
    def add_move(player_uuid, move)
      player_data[player_uuid] = move
      Player.mark_active(player_uuid)
      waiting_players << player_uuid

      if active?
        remaining_players = Set.new(Player.recent.map(&:uuid)) - waiting_players
        puts "remaining - #{remaining_players.inspect}"

        if remaining_players.present?
          RoomEventsController.publish('/room_events/waiting', {player_uuid: player_uuid,current_round: current_number}.to_json)
        else
          advance
        end
      else
        @active = true
        advance
      end
    end

    def advance
      complete

      if recent_activity?
        start
      else
        puts 'not advancing!'
        @active = nil
      end
    end

    def waiting_players
      @waiting_players ||= Set.new([])
    end

    def current_data
      {}.tap do |data|
        data[:players] = recent_player_data
        data[:current_round] = current_number
      end
    end

    def reset #testing hax
      @player_data = @waiting_players = @current_number = nil
      @last_recent_players = @active = nil
      Player.reset
    end

    private

    def active?
      !!@active
    end

    def recent_activity?
      Player.recent.present?
    end

    def current_number
      val = @current_number
      !!val ? val.to_i : 0
    end

    def player_data
      @player_data ||= {}
    end

    def recent_player_data
      #TODO: not very efficient
      player_data.select {|k,v| Player.recent_uuid?(k) }
    end

    def start
      puts 'starting new round!'
      @current_number = current_number+1
      RoomEventsController.publish('/room_events/advance', current_data.to_json)
      curr_num = current_number
      @waiting_players = nil
      puts 'setting timer...'
      EM.add_timer(ROUND_DURATION) do
        if Round.current_data[:current_round] == curr_num
          puts "timer!"
          Round.advance
        else
          puts 'no timer'
        end
      end
    end

    def complete
      recent_players = Player.recent.map(&:uuid)
      @last_recent_players||= recent_players
      lost_players = @last_recent_players - recent_players

      lost_players.each do |uuid|
        RoomEventsController.publish('/room_events/waiting', {player_uuid: uuid,current_round: current_number}.to_json)
        @waiting_players.delete(uuid) if @waiting_players
      end
      #TODO: so race condition. wow.
      @last_recent_players = recent_players
    end
  end
end
