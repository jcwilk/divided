require 'rails_helper'

describe Participant do
  let(:player) { double(uuid: 'puuid') }
  let(:participant) { Participant.new(player: player, round: round) }

  describe '.moves' do
    let(:move_map) { {player => start_spot} }
    let(:round) { double(init_pos_map: move_map, index: 5) }

    subject { participant.moves }

    context 'for someone in the corner' do
      let(:start_spot) { [0,0] }

      it 'does not include out of bound spots' do
        expect(subject.any? {|m| m.x == -1 }).to eql(false)
      end
    end

    context 'for someone in the middle' do
      let(:start_spot) { [5,5] }

      it 'includes a full radius around them' do
        expect(subject.size).to eql(49)
      end
    end
  end
end
