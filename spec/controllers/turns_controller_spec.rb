require 'rails_helper'

describe TurnsController do
  include EMSpecRunner::Mixin

  let(:starting_move) { [0,0] }

  before do
    Round.reset
    allow_any_instance_of(Round).to receive(:get_starting_move).and_return(starting_move)
    @player = Round.new_player
  end

  em_around

  def move(*m)
    post :create, player_uuid: @player.uuid, next_pos: m
  end

  def last_published_round
    json = published_messages.select{|m| m[0] == '/room_events/advance'}.last[1]
    json ? Hashie::Mash.new(JSON.parse(json)) : nil
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

    it 'reports them as killed' do
      expect(last_published_round['killed'].sort).to eql([@player.uuid,@p2.uuid].sort)
    end

    it 'does not permit further moves from the players' do
      move(3,3)
      expect(response.status).to eql(403)
    end
  end
end
