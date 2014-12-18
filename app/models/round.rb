class Round
  ROUND_DURATION = 5 #seconds

  class << self
    delegate :waiting_players, :move_map, :current_data,
      :add_move, :new_player, to: :current_round

    def advance
      current_round.complete

      all << new(current_round)

      current_round.start
    end

    def reset #testing hax
      @all = nil
      Player.reset
    end

    def last_round
      all[-2] || new
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

  attr_reader :waiting_map, :index, :move_map

  def initialize(father = nil)
    @waiting_map = {}
    if father
      @index = father.index + 1
      @move_map = father.move_map_with_new.dup
      @last_participants = father.participants
    else
      @index = 0
      @move_map = {}
      @last_participants = Player.recent
    end
  end

  def new_player
    Player.new_active.tap {|p| add_move(p) }
  end

  def add_move(player, move = nil)
    if move_map.key?(player)
      raise ArgumentError, "Must provide move on subsequent turns" if move.nil?
      if !valid_move?(player,move)
        return false
      end
    else
      move = get_starting_move(player.uuid)
    end

    player.touch
    waiting_map[player] = move

    remaining_players = Set.new(participants) - waiting_players
    puts "remaining - #{remaining_players.inspect}"

    if remaining_players.present?
      puts 'peeps remaining!'
      RoomEventsController.publish('/room_events/waiting', {player_uuid: player.uuid,current_round: index}.to_json)
    else
      puts 'advancin'
      Round.advance
    end

    true
  end

  def waiting_players
    Set.new(waiting_map.keys)
  end

  def current_data
    {}.tap do |data|
      data[:players] = recent_move_map.reduce({}) {|a,(k,v)| a.merge(k.uuid => v) }
      data[:current_round] = index
    end
  end

  def recent_move_map
    #TODO: cache this less painfully
    p = Set.new(participants.map(&:uuid))
    prior_data = move_map_with_new.select {|k,v| p.include?(k.uuid) }
  end

  def move_map_with_new
    move_map.merge(waiting_map)
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

  def valid_move?(player,move)
    last_move = move_map[player]
    return false if last_move.nil?
    return false if move[0] < 0 || move[0] > 9 || move[1] < 0 || move[1] > 9

    [(move[0]-last_move[0]).abs,(move[1]-last_move[1]).abs].max < 4
  end

  def get_starting_move(uuid)
    [
      (Digest.hexencode(uuid).to_i(16)/13%2)*9,
      (Digest.hexencode(uuid).to_i(16)/7%2)*9
    ]
  end
end
