require 'rails_helper'

describe MoveGenerator do
  let(:uuid) { 'some_uuid' }
  let(:enemy_uuid) { 'enemy_uuid' }
  let(:player) { double(uuid: uuid) }
  let(:participant) { double(player: player, attacked_recently?: false) }
  let(:enemy) { double(uuid: enemy_uuid) }
  let(:init_pos_map) {{
    player => [0,0]
  }}
  let(:round) { double(init_pos_map: init_pos_map, index: 5) }
  let(:gen) { MoveGenerator.new(participant: participant, round: round) }

  describe 'stationary_move' do
    subject { gen.stationary_move }

    it 'has an action of "wait"' do
      expect(subject.action).to eql('wait')
    end

    it 'has coordinates matching those of the player' do
      expect([subject.x,subject.y]).to eql(init_pos_map[player])
    end
  end

  describe 'moves' do
    subject { gen.moves }

    it 'does not include out of bounds moves' do
      expect(subject.any? {|m| m.x == -1 && m.y == -1 }).to eql(false)
    end

    it 'returns moves in a consistent order' do
      expect(subject).to eql(gen.moves)
    end

    it 'does not include the spot they stand on' do
      expect(subject.any? {|m| [m.x,m.y] == [0,0] }).to eql(false)
    end

    context 'for someone in the corner' do
      it 'does not include out of bound spots' do
        expect(subject.any? {|m| m.x == -1 }).to eql(false)
      end
    end

    context 'for someone in the middle' do
      let(:init_pos_map) {{
        player => [5,5]
      }}

      it 'includes a full radius around them' do
        expect(subject.size).to eql(48)
      end
    end

    describe 'with a nearby opponent' do
      let(:init_pos_map) {{
        player => [0,0],
        enemy => [2,2]
      }}

      it 'does not include actions for the enemy occupied tile' do
        expect(subject.any? {|m| m.x == 2 && m.y == 2 }).to eql(false)
      end

      context 'when the enemy is not adjacent' do
        it 'does not include attack actions for the tiles adjacent to the enemy' do
          expect(subject.any? {|m| m.x == 1 && m.y == 3 && m.action == 'attack' }).to eql(false)
        end
      end

      context 'when the enemy is adjacent' do
        let(:init_pos_map) {{
          player => [1,1],
          enemy => [2,2]
        }}        

        it 'includes attack actions for the tiles adjacent to the enemy' do
          expect(subject.any? {|m| m.x == 1 && m.y == 3 && m.action == 'attack' }).to eql(true)
        end

        it 'does not include run actions for the tiles adjacent to the enemy' do
          expect(subject.any? {|m| m.x == 1 && m.y == 2 && m.action == 'run' }).to eql(false)
        end

        it 'only includes adjacent run actions' do
          expect(subject.any? {|m| m.action == 'run' && ((m.x - 1).abs > 1 || (m.y - 1).abs > 1) }).to eql(false)
        end
      end

      context 'when the collision sim does not return collisions' do
        before do
          allow_any_instance_of(CollisionSimulator).to receive(:collisions).and_return([])
        end

        it 'returns moves on the other side of the enemy' do
          expect(subject.any? {|m| m.x == 3 && m.y == 3 }).to eql(true)
        end
      end

      context 'when the collision sim does return collisions' do
        it 'does not return moves on the other side of the enemy' do
          expect(subject.any? {|m| m.x == 3 && m.y == 3 }).to eql(false)
        end

        it 'does return moves in front of the enemy' do
          expect(subject.any? {|m| m.x == 1 && m.y == 1 }).to eql(true)
        end
      end
    end
  end
end
