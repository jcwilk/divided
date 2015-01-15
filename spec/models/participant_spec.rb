require 'spec_helper'

describe Participant do
  describe '.calculate_moves' do
    context 'for someone in the corner' do
      it 'does not include out of band spots'
    end

    context 'for someone in the middle' do
      it 'includes a full radius around them'
    end
  end
end
