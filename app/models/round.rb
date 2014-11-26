class Round
  def self.advance
    redis.set('round:current_number', current_number+1)
  end

  def self.current_number
    val = redis.get('round:current_number')
    !!val ? val.to_i : 0
  end

  def self.reset
    redis.set('round:current_number', nil)
  end

  def self.redis
    RedisClient.client
  end
end
