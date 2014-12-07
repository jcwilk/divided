require 'rails_helper'

describe Round do
  delegate :defer, :stop, to: EM

  before { Round.reset }

  around(:each) do |example|
    @explicit_finish = false
    EM.run do
      puts 'running'
      example.run
      finish if !@explicit_finish

      EM.add_timer(5) do
        fail "out of time!"
      end
    end
  end

  def finish(&block)
    @explicit_finish = true
    defer do
      block.call if block
      stop
    end
  end

  describe 'adding a move' do
    let(:new_uuid) { 'new-uuid' }
    let(:move) { [0,0] }

    def add_move(uuid = new_uuid)
      Round.add_move(uuid,move)
    end

    def recent_players
      Player.recent.map(&:uuid)
    end

    shared_examples_for "single player mode" do
      it 'advances the round' do
        finish do
          expect { add_move }.to change { Round.current_number }.by(1)
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
        add_move('old-uuid')
      end

      it 'does not advance the round' do
        expect { add_move }.not_to change { Round.current_number }
      end

      it 'leaves only the new player as waiting' do
        add_move
        expect(Round.waiting_players.to_a).to eql(['new-uuid'])
      end

      it 'includes both players in the recently moved list' do
        add_move
        expect(recent_players.sort).to eql(['old-uuid',new_uuid].sort)
      end
    end

    context 'after another player has moved long ago' do
      before do
        add_move('old-uuid')
        Timecop.travel(Time.now+Round::PLAYER_EXPIRE*2)
      end

      it_behaves_like "single player mode"
    end
  end
end
