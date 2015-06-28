class Participant < Hashie::Dash
  property :player, required: true
  property :round,  required: true

  delegate :uuid, to: :player
  delegate :moves, to: :move_generator

  def default_move
    m = moves
    m.find {|el| [el.x,el.y] == init_pos } || m.first
  end

  def choose_move(id)
    move_by_id(id).tap do |move|
      round.add_move(player: player, move: move) if move
    end
  end

  def move_by_id(id)
    moves.find {|m| m.id == id }
  end

  def round_id
    round.index
  end

  private

  def move_generator
    MoveGenerator.new(player: player, round: round)
  end

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
