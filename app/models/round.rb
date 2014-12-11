class Round
  ROUND_DURATION = 5 #seconds

  class << self
    delegate :waiting_players, :player_data, :current_data,
      to: :current_round

    def add_move(player_uuid, move)
      player_data[player_uuid] = move
      Player.mark_active(player_uuid)
      waiting_players << player_uuid

      if active?
        remaining_players = Set.new(Player.recent.map(&:uuid)) - waiting_players
        puts "remaining - #{remaining_players.inspect}"

        if remaining_players.present?
          puts 'peeps remaining!'
          RoomEventsController.publish('/room_events/waiting', {player_uuid: player_uuid,current_round: current_number}.to_json)
        else
          puts 'advancin'
          advance
        end
      else
        puts 'not active'
        @active = true
        advance
      end
    end

    def advance
      current_round.complete

      if recent_activity?
        start
      else
        puts 'not advancing!'
        @active = nil
      end
    end

    def reset #testing hax
      @all = nil
      @active = nil
      Player.reset
    end

    def current_round
      all.last
    end

    def current_number
      current_round.index
    end

    private

    def all
      @all ||= [new]
    end

    def active?
      !!@active
    end

    def recent_activity?
      Player.recent.present?
    end

    def current_number
      all.length-1
    end

    def start
      all << new(current_round)
      curr_num = current_number
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
  end

  attr_reader :participants, :waiting_players, :index, :player_data

  def initialize(father = nil)
    @waiting_players = []
    if father
      @index = father.index + 1
      @player_data = father.player_data.dup
      @last_participants = father.participants
    else
      @index = 0
      @player_data = {}
      @last_participants = Player.recent
    end
  end

  def current_data
    {}.tap do |data|
      data[:players] = recent_player_data
      data[:current_round] = index
    end
  end

  def recent_player_data
    #TODO: make this draw off participants
    player_data.select {|k,v| Player.recent_uuid?(k) }
  end

  def participants
    @participants || Player.recent
  end


  def complete
    @participants = participants
    RoomEventsController.publish('/room_events/advance', current_data.to_json)
  end
end
