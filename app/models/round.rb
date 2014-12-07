module Round
  ROUND_DURATION = 5 #seconds
  PLAYER_EXPIRE = ROUND_DURATION*5 #seconds

  def self.advance
    recent_players = Player.recent.map(&:uuid)
    @last_recent_players||= recent_players
    lost_players = @last_recent_players - recent_players

    lost_players.each do |uuid|
      RoomEventsController.publish('/room_events/waiting', {player_uuid: uuid,current_round: current_number}.to_json)
      @waiting_players.delete(uuid) if @waiting_players
    end
    #TODO: so race condition. wow.
    @last_recent_players = recent_players

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
    Player.recent.present?
  end

  def self.current_number
    val = @current_number
    !!val ? val.to_i : 0
  end

  def self.add_move(player_uuid, move)
    player_data[player_uuid] = move
    new_move = !Player.recent_uuid?(player_uuid)
    Player.mark_active(player_uuid)
    waiting_players << player_uuid

    p waiting_players

    if active?
      remaining_players = Set.new(Player.recent.map(&:uuid)) - waiting_players
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
    #TODO: not very efficient
    player_data.select {|k,v| Player.recent_uuid?(k) }
  end

  def self.current_data
    {}.tap do |data|
      data[:players] = recent_player_data
      data[:current_round] = current_number
    end
  end

  def self.recent_players_map
    @recent_players_map||= {}
  end

  def self.reset #testing hax
    @player_data = @waiting_players = @current_number = nil
    @last_recent_players = @active = nil
    Player.reset
  end
end
