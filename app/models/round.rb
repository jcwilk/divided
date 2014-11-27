module Round
  def self.advance
    if recent_activity?
      puts 'advancing!'
      @current_number = current_number+1
      RoomEventsController.publish('/room_events/advance', current_data.to_json)
      curr_num = current_number
      @waiting_players = nil
      EM.add_timer(5) do
        if Round.current_number == curr_num
          puts "timer!"
          Round.advance
        end
      end
    else
      puts 'not advancing!'
      @active = nil
    end
  end

  def self.active?
    !!@active
  end

  def self.recent_activity?
    @last_move && Time.now - @last_move < 20
  end

  def self.current_number
    val = @current_number
    !!val ? val.to_i : 0
  end

  def self.add_move(player_uuid, move)
    player_data[player_uuid] = move
    @last_move = Time.now
    new_move = !recent_players_map[player_uuid]
    recent_players_map[player_uuid] = Time.now
    waiting_players << player_uuid

    p recent_player_data
    p waiting_players

    if active?
      remaining_players = Set.new(recent_players) - waiting_players
      puts "remaining - #{remaining_players}"

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

  def self.waiting_players
    @waiting_players ||= Set.new([])
  end

  def self.player_data
    @player_data ||= {}
  end

  def self.recent_player_data
    player_data.select {|k,v| recent_players.include?(k) }
  end

  def self.current_data
    {}.tap do |data|
      data[:players] = recent_player_data
      data[:current_round] = current_number
    end
  end

  def self.recent_players
    recent_players_map.select {|k,v| Time.now - v < 10 }.keys.tap{|players| puts "#{players.size} players"}
  end

  def self.recent_players_map
    @recent_players_map||= {}
  end
end
