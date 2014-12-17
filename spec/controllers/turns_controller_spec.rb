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

  def last_published
    json = published_messages.last[1]
    json ? Hashie::Mash.new(JSON.parse(json)) : nil
  end

  def last_published_move
    last_published.players[@player.uuid]
  end

  it 'allows a move 3 tiles away' do
    move(3,3)
    expect(response.status).to eql(200)
    expect(last_published.players[@player.uuid]).to eql([3,3])
  end

  it 'does not allow a move 4 tiles away' do
    move(3,4)
    expect(response.status).to eql(422)
    expect(last_published_move).not_to eql([3,4])
  end

  it 'does not allow a move out of bounds' do
    move(-1,0)
    expect(response.status).to eql(422)
    expect(last_published_move).not_to eql([-1,0])
  end
end
