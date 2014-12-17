require 'rails_helper'

describe Round do
  include EMSpecRunner::Mixin

  before do
    Round.reset
  end

  em_around

  describe '.new_player' do
    subject { Round.new_player }

    it 'adds a new recent player' do
      expect { subject }.to change { Player.recent.size }.by(1)
    end

    it 'returns a player with a uuid' do
      expect(subject.uuid).to be_a(String)
    end
  end

  describe 'adding a move' do
    let(:new_player) { Player.new_active(new_uuid) }
    let(:new_uuid) { 'new-uuid' }
    let(:move) { [0,0] }

    def add_move(player = new_player)
      Round.add_move(player,move)
    end

    def recent_players
      Player.recent.map(&:uuid)
    end

    def current_round
      Round.current_data[:current_round]
    end

    shared_examples_for "single player mode" do
      it 'advances the round' do
        finish do
          expect { add_move }.to change { current_round }.by(1)
        end
      end

      it 'leaves no waiting players' do
        finish do
          add_move
          expect(Round.waiting_players).to be_empty
        end
      end

      it 'only adds the new player to the recent players list' do
        finish do
          add_move
          expect(recent_players).to eql([new_uuid])
        end
      end
    end

    context 'to a blank room' do
      it_behaves_like "single player mode"
    end

    context 'after another player has recently moved' do
      before do
        add_move(Player.new_active('old-uuid'))
      end

      it 'does not advance the round' do
        expect { add_move }.not_to change { current_round }
      end

      it 'leaves only the new player as waiting' do
        add_move
        expect(Round.waiting_players.to_a.map(&:uuid)).to eql(['new-uuid'])
      end

      it 'includes both players in the recently moved list' do
        add_move
        expect(recent_players.sort).to eql(['old-uuid',new_uuid].sort)
      end

      context 'and after the max round duration has elapsed' do
        before do
          @old_round = current_round
          add_move
        end

        it 'advances the round' do
          finish_in(Round::ROUND_DURATION) do
            expect(current_round).to eql(@old_round+1)
          end
        end
      end
    end

    context 'after another player has moved long ago' do
      before do
        add_move(Player.new_active('old-uuid'))
        Timecop.travel(Time.now+Player::PLAYER_EXPIRE*2)
      end

      it_behaves_like "single player mode"
    end

    context 'as a first move with recent players' do
      before do
        add_move(Player.new_active('old-uuid'))
      end

      it 'ignores their chosen position' do
        #NB: Must be a move the server will never choose
        Round.add_move(new_player,[1,1])
        finish do
          expect(Round.current_round.recent_move_map[new_uuid]).not_to eql([1,1])
        end
      end
    end

    context 'when choosing a spot out of the grid' do
      let(:move) { [-1,0] }

      before do
        add_move
      end

      # it 'returns false' do
      #   finish_in(5.1) do
      #     expect(Round.add_move(new_uuid,move)).to be_false
      #   end
      # end
    end

    context 'when choosing a spot more than 3 squares away from your previous spot' do
      before do
        add_move
        @move = Round.current_data[:players][new_uuid].dup
        @move[0] = (@move[0]-9)*-1
        @move[1] = (@move[1]-9)*-1
      end

      # it 'returns false' do
      #   finish_in(5.1) do
      #     expect(Round.add_move(new_uuid,@move)).to be_false
      #   end
      # end
    end
  end
end
