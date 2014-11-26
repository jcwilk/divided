class TestsController < ApplicationController
  include ActionController::Live

  def show
    if params[:id] == "delay"
      secs = (params[:seconds] || 10).to_i
      EM.add_timer(5) do
        puts "hello!"
      end
      sleep(secs)
      render text: "Good morning, I slept for many seconds... at least #{secs}!"
      puts "hi!"
    elsif params[:id] == "stream"
      as_stream do
        loop do
          response.stream.write("data: {so: {much: 'JSON'}}\n\n")
          sleep 1
        end
      end
    elsif params[:id] == "pub"
      $redis.publish('blah.yep', {event: {json: 'yay!'}}.to_json)
      $redis.incr('counter')
      $redis.set('fake_event',{event: {json: 'yay!'}}.to_json)
      render text: "published!"
    elsif params[:id] == 'sub'
      as_stream do
        response.stream.write("data: Listening!\n\n")
        $redis.subscribe('blah.yep') do |on|
          on.message do |event, data|
            response.stream.write("data: #{data}\n\n")
          end
        end
      end
    elsif params[:id] == 'poll'
      as_stream do
        response.stream.write("data: Listening!\n\n")
        old_val = nil
        loop do
          new_val = $redis.get('counter')
          if new_val != old_val
            old_val = new_val
            response.stream.write("data: #{$redis.get('fake_event')}\n\n")
          end
          sleep 0.5
        end
      end
    else
      render text: "wrong test id!"
    end
  end

  private

  def as_stream(&block)
    # SSE expects the `text/event-stream` content type
    response.headers['Content-Type'] = 'text/event-stream'
    begin
      block.call
    rescue IOError, Timeout::Error
      # When the client disconnects, we'll get an IOError on write
      # Or, more likely, Timeout will kill us
    ensure
      response.stream.close
    end
  end
end
