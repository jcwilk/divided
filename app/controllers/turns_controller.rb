class TurnsController < ApplicationController
  include ActionController::Live

  def index
    player_uuid = params[:player_uuid]
    puts "FIRST#{player_uuid}"

    # SSE expects the `text/event-stream` content type
    response.headers['Content-Type'] = 'text/event-stream'
    puts "SECOND#{player_uuid}"
    response.stream.write("data: and so it begins!\n\n")
    puts "SECONDnAhalf#{player_uuid}"
    # loop do
    #   sleep 5
    # end

    begin
      stream_new_round(current_round_json)
      puts "THIRD#{player_uuid}"
      subscribe_to_turns do |data|
        stream_new_round(data)
        #redis.zadd('players', current_time_score, player_uuid)
      end
    rescue IOError
      # When the client disconnects, we'll get an IOError on write
    ensure
      response.stream.close
    end
  end

  def create
    head :ok, content_type: 'text/html'
    return

    puts "starting with: #{redis.zcount('players',current_time_score-5,'+inf').inspect}"
    if params[:current_round].present? && params[:current_round].to_i == Round.current_number
      redis.sadd('pending_movers', params[:player_uuid])
      redis.zadd('players', current_time_score, params[:player_uuid])
      redis.set("next_pos:#{params[:player_uuid]}",params[:next_pos].map(&:to_i).to_json)
      if (redis.zrangebyscore('players',current_time_score-5,'+inf') - redis.smembers('pending_movers')).empty?
        Round.advance
        publish_turn
        redis.del('pending_movers')
      end
    end
    puts "ending with: #{redis.zcount('players',current_time_score-5,'+inf').inspect}"

    #TODO: conditionally confirm to the client so it can give feedback to
    # the player that the directive has been queued
    head :ok, content_type: 'text/html'
  end

  private

  def publish_turn
    json = current_round_json
    redis.publish('turns.new', json)
    redis.incr('counter')
    redis.set('fake_event',json)
  end

  def subscribe_to_turns(&block)
    old_val = redis.get('counter')
    loop do
      sleep 0.5
      new_val = redis.get('counter')
      if new_val != old_val
        old_val = new_val
        block.call(redis.get('fake_event'))
      end
    end
  end

  # def subscribe_to_turns(&block)
  #   redis.subscribe('turns.new') do |on|
  #     on.message do |event, data|
  #       block.call(data)
  #     end
  #   end
  # end

  def current_time_score
    Time.now.to_i
  end

  def redis
    #@redis ||= Redis.new
    RedisClient.client
  end

  def current_round_json
    {}.tap do |data|
      data[:players] = {}
      redis.zrangebyscore('players',current_time_score-60,'+inf').each do |id|
        data[:players][id] = JSON.parse(redis.get("next_pos:#{id}"))
      end
      data[:current_round] = Round.current_number
    end.to_json
  end

  def stream_new_round(data)
    response.stream.write("event: turns.new\n")
    response.stream.write("data: #{ data }\n\n")
  end
end
