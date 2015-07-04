require 'rails_helper'

describe Participant do
  let(:player) { double(uuid: 'puuid') }
  let(:participant) { Participant.new(player: player, round: round) }
  let(:move_map) { {player => start_spot} }
  let(:round) { double(init_pos_map: move_map, index: 5) }
  let(:start_spot) { [0,0] }

  describe '.choose_move' do
    before do      
      allow(round).to receive(:add_move)
    end

    context 'when passed an invalid index' do
      def choose_invalid
        participant.choose_move(100)
      end

      it 'does not choose the move' do
        expect(round).not_to receive(:add_move)
        choose_invalid
      end

      it 'returns nil' do
        expect(choose_invalid).to be_nil
      end
    end
  end

  describe '.moves' do
    subject { participant.moves }

    it 'does not include the spot they stand on' do
      expect(subject.any? {|m| [m.x,m.y] == start_spot }).to eql(false)
    end

    context 'for someone in the corner' do
      let(:start_spot) { [0,0] }

      it 'does not include out of bound spots' do
        expect(subject.any? {|m| m.x == -1 }).to eql(false)
      end
    end

    context 'for someone in the middle' do
      let(:start_spot) { [5,5] }

      it 'includes a full radius around them' do
        expect(subject.size).to eql(48)
      end
    end
  end
end
