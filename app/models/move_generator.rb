class MoveGenerator
  delegate :uuid, to: :player
  delegate :init_pos_map, to: :round

  attr_reader :player, :round

  def initialize(player:, round:)
    @player = player
    @round = round
  end

  def moves
    [].tap do |valid_moves|
      tentative_move_data.each {|t|
        move = Move.new(t.merge(
          player_uuid: player.uuid,
          id: valid_moves.size,
          round_id: round.index
        ))
        valid_moves << move if move.valid?
      }
    end
  end

  private

  def tentative_move_data
    [].tap do |tentatives|
      x,y = init_pos_map[player]
      ((x-3)..(x+3)).each do |xi|
        ((y-3)..(y+3)).each do |yi|
          tentatives << tentative_move_data_for_xy(xi,yi)
        end
      end
    end.flatten
  end

  def tentative_move_data_for_xy(x,y)
    [].tap do |tentatives|
      if !init_pos_map.any? {|k,v| v == [x,y] && k != player }
        tentatives << {
          x: x,
          y: y,
          action: 'run'
        }

        if init_pos_map.any? {|k,v| (v[0] - x).abs <= 1 && (v[1] - y).abs <= 1 && k != player }
          tentatives << {
            x: x,
            y: y,
            action: 'attack'
          }
        end
      end
    end
  end
end
