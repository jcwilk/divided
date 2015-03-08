require 'hashie'
require 'roar/decorator'
require 'roar/json'

class Player < Hashie::Dash
  class << self
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

  property :uuid, required: false

  def initialize(*args)
    super
    @alive = true
    extend Player::Representer
  end

  def kill
    @alive = false
  end

  def alive?
    @alive
  end

  #TODO: remove this
  module Representer
    include Roar::JSON

    property :uuid
    property :last_seen
  end
end
