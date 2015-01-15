class Participant
  class Move < Hashie::Dash
    property :player_uuid, required: true
    property :x, required: true
    property :y, required: true
  end

  class << self
    alias_method :from_player, :new
    private :new
  end

  attr_reader :player

  def calculate_moves(round:)
    #TODO: this needs to take into account a
    # -lot- more things, but for now it's all
    # that's needed
    x,y = round.living_recent_move_map[player]
    #...
  end
