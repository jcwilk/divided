require 'hashie'
require 'roar/decorator'
require 'roar/json'

class Player < Hashie::Dash
  class << self
    def recent
      all.select {|p| p.last_seen > Time.now - PLAYER_EXPIRE }
    end

    def recent_uuid?(uuid)
      recent.any? {|p| p.uuid == uuid }
    end

    def get_by_uuid(uuid)
      all.find {|p| p.uuid == uuid }
    end

    # def waiting

    # end

    def new_active(uuid = nil)
      uuid ||= SecureRandom.urlsafe_base64(8)

      new(uuid: uuid).tap do |p|
        all << p
      end
    end

    def mark_active(uuid)
      player = get_by_uuid(uuid)
      if player
        player.touch
      else
        all << new(uuid: uuid)
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
    extend Player::Representer
  end

  def touch
    @last_seen = Time.now
  end

  # class CollectionRepresenter < Roar::Decorator
  #   include Roar::JSON

  #   collection :players, extend: Player::Representer, class: Player
  # end

  module Representer
    include Roar::JSON

    property :uuid
    property :last_seen
  end
end
