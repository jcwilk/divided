module Round
  def self.advance
    if recent_activity?
      puts 'advancing!'
      @current_number = current_number+1
      RoomEventsController.publish('/room_events', current_data.to_json)
      Round.reset
      curr_num = current_number
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
    recent_players_map[player_uuid] = Time.now
    if !active? || (recent_players - player_data.keys).empty?
      @active = true
      advance
    end
  end

  def self.player_data
    @player_data ||= {}
  end

  def self.reset
    @player_data = {}
  end

  def self.current_data
    {}.tap do |data|
      data[:players] = player_data
      data[:current_round] = current_number
    end
  end

  def self.recent_players
    recent_players_map.find_all {|k,v| Time.now - v < 10 }.map(&:first).tap{|players| puts "#{players.size} players"}
  end

  def self.recent_players_map
    @recent_players_map||= {}
  end
end
