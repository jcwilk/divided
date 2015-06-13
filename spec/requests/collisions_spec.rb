require 'rails_helper'

describe 'collisions between players' do
  let!(:p1) { Player.new_active }
  let!(:p2) { Player.new_active }

  em_around

  def set_starting_move(x,y)
    allow_any_instance_of(Round).to receive(:get_starting_move).and_return([x,y])
  end

  context 'with two players 2 tiles apart' do
    before do
      set_starting_move(0,0)
      Round.current_round.join(p1)
      set_starting_move(0,3)
      Round.current_round.join(p2)
    end

    context 'when a player tries to move onto another player' do
      before do
        EM.add_timer(Round::ROUND_DURATION+1) do
          move = available_moves(p1.uuid).find {|i| i.action == 'run' && i.x == 0 && i.y == 3 }
          move.post
        end
      end

      it 'the player stops in front of them' do
        finish_in(Round::ROUND_DURATION*2+1) do
          expect(last_published_round.players[p1.uuid]).to eql([0,2])
        end
      end
    end
  end
end
