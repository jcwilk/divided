require 'rails_helper'

describe "turn advancement" do
  let(:starting_move) { [0,0] }
  let(:client) { dv_client }

  before do
    allow_any_instance_of(Round).to receive(:get_starting_move).and_return(starting_move)
    @player = Round.new_player
  end

  em_around

  def move(x,y)
    m = fetch_move(x,y)
    fail "no move matches #{x},#{y}" if m.nil?
    m.post
  end

  def fetch_move(x,y)
    available_moves(@player.uuid).find {|i| i.x == x && i.y == y }
  end

  def last_published_move
    last_published_round.players
  end

  def last_published_player_move
    last_published_move[@player.uuid]
  end

  it 'allows a move 3 tiles away' do
    r=move(3,3)
    expect(r.response.status).to eql(201)
    expect(last_published_player_move).to eql([3,3])
  end

  it 'does not allow a move 4 tiles away' do
    expect(fetch_move(3,4)).to be_nil
  end

  it 'does not allow a move out of bounds' do
    expect(fetch_move(-1,0)).to be_nil
  end

  context 'if the player stays in place for more than the expiry time' do
    def wait_too_long(&block)
      finish_in(Player::PLAYER_EXPIRE*2) do
        block.call
      end
    end

    it 'kills the player' do
      proc = Proc.new do
        move(0,0) rescue nil
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
      move_p2(2,2)
      move(3,3)
    end

    def move_p2(x,y)
      m = fetch_move_p2(x,y)
      fail "no move matches #{x},#{y}" if m.nil?
      m.post
    end

    def fetch_move_p2(x,y)
      available_moves(@p2.uuid).find {|i| i.x == x && i.y == y }
    end

    it 'permits the moves' do
      expect(last_published_move).to eql(@player.uuid => [3,3], @p2.uuid => [2,2])
    end

    it 'reports only the player who moved more as killed' do
      expect(last_published_round['killed']).to eql([@p2.uuid])
    end

    it 'does not permit further moves from the dead player' do
      expect(get_participant_by_uuid(@p2.uuid)).to be_nil
    end

    it 'reverts to single player mode for the living player' do
      published_messages.clear
      move(4,4)
      expect(last_published_move.keys).to include(@player.uuid)
    end

    it 'the dead player will not kill players in future rounds' do
      p3 = Round.new_player
      finish_in(6) do
        available_moves(p3.uuid).find {|i| i.x == 1 && i.y == 1 }.post
        expect(Player.alive_by_uuid(p3.uuid)).to be_present
      end
    end
  end
end
