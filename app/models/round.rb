class Round
  ROUND_DURATION = 5 #seconds

  class << self
    delegate :waiting_players, :player_data, :current_data, :add_move,
      to: :current_round

    def advance
      current_round.complete

      all << new(current_round)

      current_round.start
    end

    def reset #testing hax
      @all = nil
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

  def add_move(player_uuid, move)
    player_data[player_uuid] = move
    Player.mark_active(player_uuid)
    waiting_players << player_uuid

    remaining_players = Set.new(participants.map(&:uuid)) - waiting_players
    puts "remaining - #{remaining_players.inspect}"

    if remaining_players.present?
      puts 'peeps remaining!'
      RoomEventsController.publish('/room_events/waiting', {player_uuid: player_uuid,current_round: index}.to_json)
    else
      puts 'advancin'
      Round.advance
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

  def start
    return if participants.blank?

    curr_index = index
    EM.add_timer(ROUND_DURATION) do
      Round.advance if Round.current_number == curr_index
    end
  end

  def complete
    @participants = participants
    RoomEventsController.publish('/room_events/advance', current_data.to_json)
  end

  private

  def deferred_advance
    @deferred_advance
  end
end
