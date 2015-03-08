require 'rails_helper'

describe Player do
  let(:uuid) { 'some-uuid' }

  def recent_player?
    Player.recent_uuid?(uuid)
  end

  describe '.new_active' do
    subject { Player.new_active }

    its(:uuid) { should be_a(String) }

    it 'is retrievable' do
      expect(Player.alive_by_uuid(subject.uuid)).to eql(subject)
    end

    it 'is alive' do
      expect(subject).to be_alive
    end
  end

  describe '#kill' do
    let!(:player) { Player.new_active }

    def kill
      player.kill
    end

    it 'makes them no longer retrievable' do
      expect { kill }.to change { Player.alive_by_uuid(player.uuid) }.from(player).to(nil)
    end

    it 'makes them not alive' do
      expect { kill }.to change { player.alive? }.from(true).to(false)
    end
  end
end
