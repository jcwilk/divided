require 'hashie'
require 'roar/decorator'
require 'roar/json'

class Player < Hashie::Dash
  class << self
    def recent
      all.select {|p| p.alive? && p.last_seen > Time.now - PLAYER_EXPIRE }
    end

    def recent_uuid?(uuid)
      recent.any? {|p| p.uuid == uuid }
    end

    def alive_by_uuid(uuid)
      all.find {|p| p.alive? && p.uuid == uuid }
    end

    def new_active(uuid = nil)
      uuid ||= SecureRandom.urlsafe_base64(8)

      new(uuid: uuid).tap do |p|
        all << p
      end
    end

    def reset
      @all = nil
    end

    private

    def all
      @all ||= []
    end
  end

  PLAYER_EXPIRE = 25 #seconds

  property :uuid, required: false

  attr_reader :last_seen

  def initialize(*args)
    super
    touch
    @alive = true
    extend Player::Representer
  end

  def touch
    @last_seen = Time.now
  end

  def kill
    @alive = false
  end

  def alive?
    @alive
  end

  def moves
    (0..3).map do |id|
      Hashie::Mash.new({
        id: id,
        x: 1,
        y: 1,
        participant_uuid: uuid
      })
    end
  end

  #TODO: remove this
  module Representer
    include Roar::JSON

    property :uuid
    property :last_seen
  end
end
