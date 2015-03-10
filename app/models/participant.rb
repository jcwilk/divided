class Participant < Hashie::Dash
  class Move < Hashie::Dash
    property :player_uuid, required: true
    property :x, required: true
    property :y, required: true
    property :id, required: true
    property :round_id, required: true
    property :action, required: true

    def valid?
      x >= 0 && x <= 9 &&
        y >= 0 && y <= 9
    end
  end

  class MoveGenerator
    delegate :round, :player, :round_id, :uuid, to: :participant

    attr_reader :participant, :next_id, :moves
    private :next_id

    def initialize(participant:)
      @participant = participant
      @next_id = 0
      @moves = []
    end

    def add_attack(options)
      add_move(options.merge(action: 'attack'))
    end

    def add_run(options)
      add_move(options.merge(action: 'run'))
    end

    private

    def advance_id
      @next_id+= 1
    end

    def add_move(options)
      m = Move.new({
        player_uuid: uuid,
        id:          next_id,
        round_id:    round_id
      }.merge(options))
      if m.valid?
        advance_id
        moves << m
      else
        false
      end
    end
  end

  property :player, required: true
  property :round,  required: true

  delegate :uuid, to: :player

  def moves
    @moves ||= begin
      gen = MoveGenerator.new(participant: self)
      x,y = init_pos
      ((x-3)..(x+3)).each do |xi|
        ((y-3)..(y+3)).each do |yi|
          gen.add_run(x: xi, y: yi)

          if near_other_players?(xi,yi)
            gen.add_attack(x: xi, y: yi)
          end
        end
      end
      gen.moves
    end
  end

  def default_move
    m = moves
    m.find {|el| [el.x,el.y] == init_pos } || m.first
  end

  def choose_move(id)
    move_by_id(id).tap do |move|
      round.add_move(player: player, move: move)
    end
  end

  def move_by_id(id)
    moves.find {|m| m.id == id }
  end

  def round_id
    round.index
  end

  private

  def init_pos
    round.init_pos_map[player]
  end

  def near_other_players?(x,y)
    (round.init_pos_map.keys - [player]).any? do |p|
      px,py = round.init_pos_map[p]
      [(px-x).abs,(py-y).abs].max <= 1
    end
  end
end
