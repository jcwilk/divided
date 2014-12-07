require 'hashie'
require 'roar/decorator'
require 'roar/json'

class Player < Hashie::Dash
  class << self
    def recent
      all.select {|p| p.last_seen > Time.now - PLAYER_EXPIRE }
    end

    def waiting

    end

    def mark_active(uuid)
      player = get_by_uuid(uuid)
      if player
        player.touch
      else
        all << new(uuid: uuid)
      end
    end

    private

    def all
      @all ||= []
    end

    def get_by_uuid(uuid)
      recent.find {|p| p.uuid == uuid }
    end
  end

  PLAYER_EXPIRE = 25 #seconds

  property :uuid, required: true

  attr_reader :last_seen

  def initialize(*args)
    super
    touch
  end

  def touch
    @last_seen = Time.now
  end

  class Representer < Roar::Decorator
    include Roar::JSON

    property :uuid
  end
end
