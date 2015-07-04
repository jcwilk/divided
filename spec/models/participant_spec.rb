require 'rails_helper'

describe Participant do
  let(:player) { double(uuid: 'puuid') }
  let(:participant) { Participant.new(player: player, round: round) }
  let(:move_map) { {player => start_spot} }
  let(:round) { double(init_pos_map: move_map, index: 5, attacked_in_last_x_moves?: false) }
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
end
