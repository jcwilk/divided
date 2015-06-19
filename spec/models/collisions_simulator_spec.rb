require 'rails_helper'

describe CollisionSimulator do
  let(:sim) { CollisionSimulator.new }
  let(:participant_data) {[
    {initial: [0,0], final: [3,0], id: 'first'}
  ]}

  before do
    participant_data.each do |d|
      sim.add_participant(d)
    end
  end

  subject { sim.collisions }

  context 'with only one participant' do
    it 'has no collisions' do
      expect(subject).to be_empty
    end
  end

  context 'with one participant running along x into a stationary other' do
    let(:participant_data) {[
      {initial: [0,0], final: [3,0], id: 'first'},
      {initial: [3,0], final: [3,0], id: 'second'}
    ]}


    it 'lists only the first participant as collided' do
      expect(subject.size).to eql(1)
    end

    it 'lists the collision right before the stationary participant' do
      expect(subject.first[:final]).to eql([2,0])
    end
  end

  context 'with one participant running along y into a stationary other' do
    let(:participant_data) {[
      {initial: [0,0], final: [0,3], id: 'first'},
      {initial: [0,3], final: [0,3], id: 'second'}
    ]}

    it 'lists only the first participant as collided' do
      expect(subject.size).to eql(1)
    end

    it 'lists the collision right before the stationary participant' do
      expect(subject.first[:final]).to eql([0,2])
    end
  end

  context 'with participants moving to the same tile symmetrically' do
    let(:participant_data) {[
      {initial: [0,0], final: [3,0], id: 'first'},
      {initial: [6,0], final: [3,0], id: 'second'}
    ]}

    it 'results in only one collision' do
      expect(subject.size).to eql(1)
    end

    it 'results with one participant next to the other' do
      collided_id = subject.first[:id]
      non_collided = participant_data.find {|d| d[:id] != collided_id }
      expect((subject.first[:final][0]-non_collided[:final][0]).abs).to eql(1)
    end
  end
end
