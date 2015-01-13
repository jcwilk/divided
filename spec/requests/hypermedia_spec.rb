require 'rails_helper'

describe 'divided hypermedia' do
  #TODO: as this grows, split it into separate files

  def app
    Divided::Application
  end

  let(:client) do
    HyperResource.new(
      root: 'http://api.example.com/dv',
      faraday_options: {
        builder: Faraday::RackBuilder.new do |builder|
          builder.request :url_encoded
          builder.adapter :rack, app
        end
      }
    )
  end

  def first_room
    client.dv_rooms.first
  end

  def current_round
    first_room.dv_current_round
  end

  context 'retrieving the current round data for a room' do
    subject do
      current_round
    end

    it 'returns the round data' do
      expect(subject.index).to eql(0)
    end
  end

  context 'retrieving available moves for a player' do
    em_around

    before do
      @player = Round.new_player
      Timecop.travel(Time.now+Round::ROUND_DURATION+1)
    end

    subject do
      current_round.participants.find {|p| p.uuid == @player.uuid }.moves
    end

    it 'provides a list of available moves' do
      pending
      expect(subject.size).to be > 3
    end
  end
end
