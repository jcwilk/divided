require 'rails_helper'

describe MoveGenerator do
  let(:uuid) { 'some_uuid' }
  let(:enemy_uuid) { 'enemy_uuid' }
  let(:player) { double(uuid: uuid) }
  let(:enemy) { double(uuid: enemy_uuid) }
  let(:init_pos_map) {{
    player => [0,0]
  }}
  let(:round) { double(init_pos_map: init_pos_map, index: 5) }
  let(:gen) { MoveGenerator.new(player: player, round: round) }

  describe 'moves' do
    subject { gen.moves }

    it 'does not include out of bounds moves' do
      expect(subject.any? {|m| m.x == -1 && m.y == -1 }).to eql(false)
    end

    it 'returns moves in a consistent order' do
      expect(subject).to eql(gen.moves)
    end

    describe 'with a nearby opponent' do
      let(:init_pos_map) {{
        player => [0,0],
        enemy => [2,2]
      }}

      it 'does not include actions for the enemy occupied tile' do
        expect(subject.any? {|m| m.x == 2 && m.y == 2 }).to eql(false)
      end

      it 'includes attack actions for the tiles adjacent to the enemy' do
        expect(subject.any? {|m| m.x == 1 && m.y == 3 && m.action == 'attack' }).to eql(true)
      end
    end
  end
end
