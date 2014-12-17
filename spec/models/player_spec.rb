require 'spec_helper'

require File.join(File.dirname(__FILE__), '../../app/models/player.rb')
require 'timecop'

describe Player do
  let(:uuid) { 'some-uuid' }

  def recent_player?
    Player.recent_uuid?(uuid)
  end

  before do
    Timecop.return
  end

  describe '.new_active' do
    subject { Player.new_active }

    its(:uuid) { should be_a(String) }

    it 'is included in the recent players' do
      player = subject
      expect(Player.recent).to include(player)
    end

    it 'is not included in recent players after sufficient time' do
      subject
      expect { Timecop.travel(Time.now+Player::PLAYER_EXPIRE+1) }
        .to change { Player.recent_uuid?(subject.uuid) }.to(false)
    end
  end

  describe '#touch' do
    before do
      @player = Player.new_active
    end

    context 'when a player has become stale' do
      before do
        Timecop.travel(Time.now+Player::PLAYER_EXPIRE+1)
      end

      it 'refreshes them and returns them into recent players' do
        expect { @player.touch }.to change { Player.recent.include?(@player) }
          .to(true)
      end
    end
  end
end
