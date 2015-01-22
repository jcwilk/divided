class Room
  class << self
    def all
      [new]
    end

    def by_uuid(uuid)
      all.find {|r| r.id == uuid }
    end
  end

  def id
    'placeholder'
  end

  def current_round
    Round.current_round
  end
end
