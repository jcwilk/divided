require 'spec_helper'

require File.join(File.dirname(__FILE__), '../../app/models/player.rb')
require 'timecop'

describe Player do
  let(:uuid) { 'some-uuid' }

  def recent_player?
    Player.recent.any? {|p| p.uuid == uuid }
  end

  describe 'marking a player as active' do
    def add_player
      Player.mark_active(uuid)
    end

    it 'adds the player to the recent players list' do
      expect { add_player }.to change { recent_player? }.to(true)
    end

    context 'if the player is already active' do
      before do
        add_player
      end

      it 'does not add a duplicate' do
        expect { add_player }.not_to change { Player.recent }
      end
    end

    context 'and then letting the expiry time pass' do
      before do
        add_player
      end

      it 'no longer includes the player as recent' do
        expect { Timecop.travel(Time.now+Player::PLAYER_EXPIRE+1) }
          .to change { recent_player? }.to(false)
      end
    end
  end
end
