require 'rails_helper'

describe TurnsController do
  let(:starting_move) { [0,0] }

  before do
    allow_any_instance_of(Round).to receive(:get_starting_move).and_return(starting_move)
    @player = Round.new_player
  end

  em_around

  def move(*m)
    post :create, player_uuid: @player.uuid, next_pos: m
  end

  def last_published_move
    last_published_round.players
  end

  def last_published_player_move
    last_published_move[@player.uuid]
  end

  it 'allows a move 3 tiles away' do
    move(3,3)
    expect(response.status).to eql(200)
    expect(last_published_player_move).to eql([3,3])
  end

  it 'does not allow a move 4 tiles away' do
    move(3,4)
    expect(response.status).to eql(422)
    expect(last_published_player_move).not_to eql([3,4])
  end

  it 'does not allow a move out of bounds' do
    move(-1,0)
    expect(response.status).to eql(422)
    expect(last_published_player_move).not_to eql([-1,0])
  end

  context 'if the player stays in place for more than the expiry time' do
    def wait_too_long(&block)
      finish_in(Player::PLAYER_EXPIRE*2) do
        block.call
      end
    end

    it 'kills the player' do
      proc = Proc.new do
        move(0,0)
        EM.add_timer(3,&proc)
      end
      EM.add_timer(3,&proc)
      wait_too_long do
        kill = published_advances.find do |pub|
          JSON.parse(pub[1])['killed'].include?(@player.uuid)
        end
        expect(kill).to be_present
      end
    end
  end

  context 'after two players have moved next to each other' do
    before do
      move(3,3)
      ##
      @p2 = Round.new_player
      move(3,3)
      ##
      post :create, player_uuid: @p2.uuid, next_pos: [2,2]
      move(3,3)
    end

    it 'permits the moves' do
      expect(last_published_move).to eql(@player.uuid => [3,3], @p2.uuid => [2,2])
    end

    it 'reports only the player who moved more as killed' do
      expect(last_published_round['killed']).to eql([@p2.uuid])
    end

    it 'does not permit further moves from the dead player' do
      post :create, player_uuid: @p2.uuid, next_pos: [2,2]
      expect(response.status).to eql(403)
    end

    it 'reverts to single player mode for the living player' do
      published_messages.clear
      move(4,4)
      expect(last_published_move.keys).to include(@player.uuid)
    end

    it 'the dead player will not kill players in future rounds' do
      p3 = Round.new_player
      finish_in(6) do
        post :create, player_uuid: p3.uuid, next_pos: [1,1]
        expect(Player.alive_by_uuid(p3.uuid)).not_to be_nil
      end
    end
  end
end
