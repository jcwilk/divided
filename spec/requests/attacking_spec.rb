require 'rails_helper'

describe "attacking behavior" do
	let(:p1) { Player.new_active }
	let(:p2) { Player.new_active }
	
	em_around

  context 'after one player attacks another' do
  	let!(:game) {
	    GameRunner.new(self, {
	      p1 => [3,3],
	      p2 => [2,3]
	    })
	  }

    before do
      game.next_round do |r|
        r.choose(p2).attack(2,2)
      end
    end

    it 'permits the moves' do
      game.next_round do |r|
        expect(r.locate(p2)).to eql([2,2])
      end
    end

    it 'reports only the player who did not move as killed' do
      game.next_round do |r|
        expect(r.killed).to eql([p1.uuid])
      end
    end

    it 'does not permit further moves from the dead player' do
      game.next_round do |r|
        expect(r.participating?(p1)).to eql(false)
      end
    end

    it 'reverts to single player mode for the living player' do
      last_time = nil

      game.next_round do |r|
        last_time = Time.now
        r.choose(p2).run(3,3)
      end

      game.next_round do |r|
        expect(Time.now - last_time).to be < Round::ROUND_DURATION
      end
    end
  end

  context 'after one player dodges the attack of another' do
  	let!(:game) {
	    GameRunner.new(self, {
	      p1 => [3,3],
	      p2 => [0,0]
	    })
	  }

  	before do
      game.next_round do |r|
        r.choose(p2).run(2,2)
      end

      game.next_round do |r|
        r.choose(p2).attack(2,3)
        r.choose(p1).run(4,4)
      end
    end

    it 'does not kill the attacked player' do
    	game.next_round do |r|
    		expect(r.killed).to be_empty
    		expect(r.locate(p1)).to eql([4,4])
    	end
    end

    it 'does not permit another attack for the next two rounds' do
    	game.next_round do |r|
    		r.choose(p2).run(3,3)
    	end

    	game.next_round do |r|
    		expect { r.choose(p2).attack(3,4) }.to raise_error
    	end
    end
  end
end