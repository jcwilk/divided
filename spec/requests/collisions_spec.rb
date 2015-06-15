require 'rails_helper'

describe 'collisions between players' do
  let!(:p1) { Player.new_active }
  let!(:p2) { Player.new_active }

  em_around

  context 'with two players 2 tiles apart' do
    let(:game) {
      GameRunner.new(self, {
        p1 => [0,0],
        p2 => [0,3]
      })
    }

    context 'when a player tries to move onto another player' do
      before do
        game.next_round do |r|
          r.choose(p1).run(0,3)
        end
      end

      it 'the player stops in front of them' do
        game.next_round do |r|
          end_at = r.locate(p1)
          #TODO: needs impl
          #expect(end_at).to eql([0,2])
        end
      end
    end
  end
end
