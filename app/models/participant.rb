class Participant < Hashie::Dash
  class Move < Hashie::Dash
    property :player_uuid, required: true
    property :x, required: true
    property :y, required: true
    property :id, required: true
    property :round_id, required: true

    def valid?
      x >= 0 && x <= 9 &&
        y >= 0 && y <= 9
    end
  end

  class << self
    alias_method :from_player, :new
    private :new
  end

  delegate :uuid, to: :player

  property :player, required: true

  def calculate_moves(round:)
    x,y = round.living_recent_move_map[player]
    [].tap do |moves|
      id = 0
      ((x-3)..(x+3)).each do |xi|
        ((y-3)..(y+3)).each do |yi|
          candidate = Move.new(x:xi, y:yi, player_uuid:uuid, id:id, round_id:round_id)
          moves << candidate if candidate.valid?
          id+= 1
        end
      end
    end
  end

  def current_moves
    calculate_moves(round: current_round)
  end

  def round_id
    #TODO: might be wise to make a participant frozen to a certain rond
    current_round.index
  end

  def current_round
    Round.current_round
  end
end
