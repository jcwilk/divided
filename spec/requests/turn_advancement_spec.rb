require 'rails_helper'

describe "move submission" do
  let(:p1) { Player.new_active }

  em_around

  context 'as a single player' do
    let!(:game) {
      GameRunner.new(self, {
        p1 => [0,0]
      })
    }

    it 'allows moves to happen immediately' do
      first_turn_time = nil

      game.next_round do |r|
        first_turn_time = Time.now
        r.choose(p1).run(3,3)
      end

      game.next_round do |r|
        expect(Time.now - first_turn_time).to be < 1.second
      end
    end

    it 'allows a move 3 tiles away' do
      game.next_round do |r|
        r.choose(p1).run(3,3)
      end

      game.next_round do |r|
        expect(r.locate(p1)).to eql([3,3])
      end
    end

    it 'does not permit a move to be posted twice' do
      move = nil
      game.next_round do |r|
        move = available_moves(p1.uuid).find {|i| i.action == 'run' && i.x == 1 && i.y == 1 }
        move.post
      end

      game.next_round do |r|
        expect { move.post }.to raise_error
      end
    end

    it 'does not allow a move 4 tiles away' do
      game.next_round do |r|
        expect { r.choose(p1).run(4,4) }.to raise_error
      end
    end

    it 'does not allow a move out of bounds' do
      game.next_round do |r|
        expect { r.choose(p1).run(-1,0) }.to raise_error
      end
    end

    it 'defaults to not moving at all' do
      loc = nil
      game.next_round do |r|
        loc = r.locate(p1)
      end

      game.next_round do |r|
        expect(r.locate(p1)).to eql(loc)
      end
    end

    context 'if the player idles for too many rounds in a row' do
      before do
        Round::STATIONARY_EXPIRE_COUNT.times do
          game.next_round do |r|
            #wait
          end
        end
      end

      it 'kills the player' do
        game.next_round do |r|
          expect(r.killed).to eql([p1.uuid])
        end
      end
    end
  end

  context 'as a player alongside an idling player' do
    let(:p2) { Player.new_active }
    let!(:game) {
      GameRunner.new(self, {
        p1 => [3,3],
        p2 => [0,0]
      })
    }

    it 'delays the turn for the full round duration' do
      first_turn_time = nil

      game.next_round do |r|
        first_turn_time = Time.now
        r.choose(p1).run(3,4)
      end

      game.next_round do |r|
        # -1 due to lack of runner precision
        expect(Time.now - first_turn_time).to be > Round::ROUND_DURATION-1
      end
    end

    context 'if the idling player chooses mid round, after the first player' do
      it 'delays for only that long' do
        first_turn_time = nil

        game.next_round do |r|
          first_turn_time = Time.now
          r.choose(p1).run(3,4)
          EM.add_timer(2.5) do
            r.choose(p2).run(1,1)
          end
        end

        game.next_round do |r|
          # Accounting for runner imprecision
          expect(Time.now - first_turn_time).to be > 1.5
          expect(Time.now - first_turn_time).to be < 3.5
        end
      end
    end
  end
end
