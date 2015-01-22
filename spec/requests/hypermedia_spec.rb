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

  describe 'utlities' do
    describe 'rendering an object' do
      subject { DV::Representers::Round.render(Round.current_round) }

      it 'returns a JSON hash' do
        expect(JSON.parse(subject).class).to eql(Hash)
      end

      it 'includes the canonical hostname' do
        expect(subject.include?(Divided::CANONICAL_HOST)).to eql(true)
      end
    end
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

    def available_moves
      current_round.participants.find {|p| p.uuid == @player.uuid }.moves
    end

    subject do
      available_moves
    end

    it 'provides a list of available moves' do
      finish_in(Round::ROUND_DURATION+1) do
        expect(subject.count).to be > 3
      end
    end

    context 'and submitting one of them' do
      it 'advances the round'
    end
  end
end
