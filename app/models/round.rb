class Round
  ROUND_DURATION = 5 #seconds
  STATIONARY_EXPIRE_COUNT = 5 #rounds

  class << self
    delegate :waiting_players, :move_map, :current_data,
      :add_move, :new_player, to: :current_round

    def advance
      #TODO: this will exist in room eventually, where will `all` live?
      old = current_round
      old.complete
      all << new(old)

      current_round.start
    end

    def reset
      @all = nil
      @participant_counter = nil
    end

    def last_round
      current_round.previous
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

  attr_reader :index, :final_pos_map, :init_pos_map, :new_players_pos_map, :settled_move_map, :father
  private :new_players_pos_map, :settled_move_map, :father

  def initialize(f = nil)
    @father = f
    #TODO: make init_pos_map delegate to father?
    # initial round would need a "dummy" null round as father, but possible
    @index, @init_pos_map = if father
      [
        father.index + 1,
        father.final_pos_map.select {|k,v| !father.killed_players.include?(k) }
      ]
    else
      [
        0,
        {}
      ]
    end

    @settled_move_map = {}
    @new_players_pos_map = {}
  end

  def add_move(player:, move:)
    settled_move_map[player] = move

    if unsettled_players.present?
      RoomEventsController.publish('/room_events/waiting', {player_uuid: player.uuid,current_round: index}.to_json)
    else
      Round.advance
    end

    true
  end

  def current_data
    {}.tap do |data|
      data[:players] = final_pos_map.reduce({}) {|a,(k,v)| a.merge(k.uuid => v) }
      data[:killed] = killed_players.map(&:uuid)
      data[:current_round] = index
      data[:halRound] = DV::Representers::Round.render_hash(self)
    end
  end

  def start
    return if participating_players.blank?

    curr_index = index
    EM.add_timer(ROUND_DURATION) do
      Round.advance if Round.current_number == curr_index
    end
  end

  def complete
    killed_players.each(&:kill)

    RoomEventsController.publish('/room_events/advance', current_data.to_json)
  end

  def new_player
    Player.new_active.tap do |p|
      join(p)
    end
  end

  def join(player)
    #TODO: more graceful?
    fail "Already joined!" if participants.any? {|p| p.uuid == player.uuid }

    new_players_pos_map[player] = get_starting_move

    #TODO: should advanced only happen in later ticks?
    Round.advance if unsettled_players.empty?
  end

  def participants
    participating_players.map {|p| Participant.new(round:self,player:p) }
  end

  def killed_players
    participating_players.select do |p|
      x,y = init_pos_map[p]
      #TODO: ensure only attack moves counted here
      settled_move_map.any? {|k,v| k != p && (v.x - x).abs <= 1 && (v.y - y).abs <= 1 } \
        || stationary_too_long?(player: p)
    end
  end

  def final_pos_map
    total_move_map.reduce(new_players_pos_map) {|a,(k,v)| a.reverse_merge(k => [v.x,v.y]) }
  end

  def stationary_too_long?(options)
    stationary_for?(STATIONARY_EXPIRE_COUNT, options)
  end

  def stationary_for?(count, player:, x: nil, y: nil)
    return false if !participating_players.include?(player)
    return true if count == 0
    if x.nil? || y.nil?
      x,y = init_pos_map[player]
    end
    return false if father.nil? || [x,y] != init_pos_map[player]

    father.stationary_for?(count-1, player: player, x: x, y: y)
  end

  private

  def participating_players
    init_pos_map.keys
  end

  def settled_players
    settled_move_map.keys
  end

  def unsettled_players
    participating_players - settled_players
  end

  def default_move_map
    participating_players.reduce({}) do |acc,el|
      acc[el] = Participant.new(round: self, player: el).default_move
      acc
    end
  end

  def total_move_map
    default_move_map.merge(settled_move_map)
  end

  # def distance_moved(player)
  #   old = last_move_map[player]
  #   nu = recent_move_map[player]
  #   return 0 if old.nil? || nu.nil?

  #   [(old[0]-nu[0]).abs,(old[1]-nu[1]).abs].max
  # end

  def get_starting_move
    counter = self.class.next_participant_counter
    [
      (counter % 2)*9,
      ((counter/2) %2)*9
    ]
  end
end
