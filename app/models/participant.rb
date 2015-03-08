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

  property :player, required: true
  property :round,  required: true

  delegate :uuid, to: :player

  def moves
    @moves ||= [].tap do |m|
      x,y = init_pos
      id = 0
      ((x-3)..(x+3)).each do |xi|
        ((y-3)..(y+3)).each do |yi|
          candidate = Move.new(
            x:           xi,
            y:           yi,
            player_uuid: uuid,
            id:          id,
            round_id:    round_id,
            action:      'run'
          )
          if candidate.valid?
            m << candidate
            id+= 1
          end

          if near_other_players?(xi,yi)
            candidate = Move.new(
              x:           xi,
              y:           yi,
              player_uuid: uuid,
              id:          id,
              round_id:    round_id,
              action:      'attack'
            )
            if candidate.valid?
              m << candidate
              id+= 1
            end
          end
        end
      end
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
