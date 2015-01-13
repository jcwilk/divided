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

    #hack for starting positions
    def next_participant_counter
      @participant_counter ||= 0
      @participant_counter+= 1
    end

    def by_index(index)
      #TODO: inefficient, remove/fix me
      all.find {|r| r.index == index }
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
      @move_map = father.living_recent_move_map.dup
    else
      @index = 0
      @move_map = {}
    end
    @last_move_map = move_map.dup
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
      move = get_starting_move
    end

    waiting_map[player] = move
    player.touch if distance_moved(player) > 0

    remaining_players = Set.new(participants) - waiting_players

    if remaining_players.present?
      RoomEventsController.publish('/room_events/waiting', {player_uuid: player.uuid,current_round: index}.to_json)
    else
      Round.advance
    end

    true
  end

  def killed_players
    mm = move_map_with_new
    mm.select do |player,move|
      mm.any? do |p,m|
        p != player &&
          (move[0]-m[0]).abs <= 1 &&
          (move[1]-m[1]).abs <= 1 &&
          distance_moved(player) > distance_moved(p)
      end
    end.keys | (move_map.keys - participants)
  end

  def waiting_players
    Set.new(waiting_map.keys)
  end

  def current_data
    {}.tap do |data|
      data[:players] = recent_move_map.reduce({}) {|a,(k,v)| a.merge(k.uuid => v) }
      data[:killed] = killed_players.map(&:uuid)
      data[:current_round] = index
    end
  end

  def living_recent_move_map
    recent_move_map.select {|k,v| !killed_players.include?(k) }
  end

  def recent_move_map
    #TODO: cache this less painfully
    p = Set.new(participants.map(&:uuid))
    move_map_with_new.select {|k,v| p.include?(k.uuid) }
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
    killed_players.each(&:kill)
    RoomEventsController.publish('/room_events/advance', current_data.to_json)
  end

  private

  def last_move_map
    @last_move_map
  end

  def distance_moved(player)
    old = last_move_map[player]
    nu = recent_move_map[player]
    return 0 if old.nil? || nu.nil?

    [(old[0]-nu[0]).abs,(old[1]-nu[1]).abs].max
  end

  def valid_move?(player,move)
    last_move = move_map[player]
    return false if last_move.nil?
    return false if move[0] < 0 || move[0] > 9 || move[1] < 0 || move[1] > 9

    [(move[0]-last_move[0]).abs,(move[1]-last_move[1]).abs].max < 4
  end

  def get_starting_move
    counter = self.class.next_participant_counter
    [
      (counter % 2)*9,
      ((counter/2) %2)*9
    ]
  end
end
