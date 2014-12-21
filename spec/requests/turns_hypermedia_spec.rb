require 'rails_helper'

describe 'turns hypermedia' do
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

  context 'for a new game' do
    it 'returns the courses' do
      expect(client.get.links['sc:turns'].url).to include('/dv/turns')
    end
  end
end
