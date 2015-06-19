require 'rails_helper'

describe Round do
  em_around

  describe '.new_player' do
    let!(:player) { Round.new_player }

    subject { player }

    it 'returns a player with a uuid' do
      expect(subject.uuid).to be_a(String)
    end

    it 'joins the player into the next round' do
      p=Round.current_round.participants.find {|el| el.uuid == subject.uuid }
      expect(p).to be_present
    end
  end

  #TODO: these would be nice things to unit test, however...
  # The way Round is currently arranged makes integration testing far easier
  # describe 'adding a move' do
  #   let(:new_player) { Player.new_active(new_uuid) }
  #   let(:new_uuid) { 'new-uuid' }
  #   let!(:move) { Hashie::Mash.new(x:0,y:0) }

  #   def add_move(player = new_player)
  #     Round.add_move(player:player,move:move)
  #   end

  #   def recent_players
  #     Player.recent.map(&:uuid)
  #   end

  #   def current_round
  #     Round.current_number
  #   end

  #   shared_examples_for "single player mode" do
  #     it 'advances the round' do
  #       finish do
  #         expect { add_move }.to change { current_round }.by(1)
  #       end
  #     end
  #   end

  #   context 'to a blank room' do
  #     it_behaves_like "single player mode"
  #   end

  #   context 'after another player has recently moved' do
  #     before do
  #       add_move(Player.new_active('old-uuid'))
  #     end

  #     it 'does not advance the round' do
  #       expect { add_move }.not_to change { current_round }
  #     end

  #     context 'and after the max round duration has elapsed' do
  #       before do
  #         @old_round = current_round
  #         add_move
  #       end

  #       it 'advances the round' do
  #         finish_in(Round::ROUND_DURATION) do
  #           expect(current_round).to eql(@old_round+1)
  #         end
  #       end
  #     end
  #   end

  #   context 'after another player has moved long ago' do
  #     before do
  #       add_move(Player.new_active('old-uuid'))
  #     end

  #     it 'advances the round' do
  #       finish_in(Round::ROUND_DURATION*(Round::STATIONARY_EXPIRE_COUNT+1.1)) do
  #         expect { add_move }.to change { current_round }.by(1)
  #       end
  #     end
  #   end
  # end
end
