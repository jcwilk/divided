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

  def stationary_move
    Move.new(
      player_uuid: player.uuid,
      id: 'pass',
      round_id: round.index,
      x: init_pos_map[player][0],
      y: init_pos_map[player][1],
      action: 'wait'
    )
  end

  private

  def tentative_move_data
    [].tap do |tentatives|
      x,y = player_pos
      ((x-3)..(x+3)).each do |xi|
        ((y-3)..(y+3)).each do |yi|
          tentatives << tentative_move_data_for_xy(xi,yi)
        end
      end
    end.flatten
  end

  def tentative_move_data_for_xy(x,y)
    return [] if player_pos == [x,y] || collisions_for_xy?(x,y)

    [].tap do |tentatives|
      if !all_enemy_pos.any? {|p| p == [x,y] }
        tentatives << {
          x: x,
          y: y,
          action: 'run'
        }

        if all_enemy_pos.any? {|ex,ey| (ex - x).abs <= 1 && (ey - y).abs <= 1 }
          tentatives << {
            x: x,
            y: y,
            action: 'attack'
          }
        end
      end
    end
  end

  def all_enemy_pos
    init_pos_map.select {|k,v| k != player }.values
  end

  def player_pos
    init_pos_map[player]
  end

  def collisions_for_xy?(x,y)
    px,py = player_pos
    all_enemy_pos_between = all_enemy_pos.select do |ex,ey|
      x_range = [px,x].sort
      y_range = [py,y].sort
      (x_range[0]..x_range[1]).include?(ex) && (y_range[0]..y_range[1]).include?(ey)
    end

    if all_enemy_pos_between.empty?
      false
    else
      sim = CollisionSimulator.new
      sim.add_participant(
        initial: player_pos,
        final: [x,y],
        id: 'player'
      )
      all_enemy_pos_between.each_with_index do |enemy_pos,i|
        sim.add_participant(
          initial: enemy_pos,
          final: enemy_pos,
          id: i
        )
      end

      sim.collisions.present?
    end
  end
end
