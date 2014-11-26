class RoomEventsController < FayeRails::Controller
  channel '/room_events' do
    monitor :subscribe do
      puts "new sub!"
    end
    monitor :unsubscribe do
      puts "lost sub!"
    end
    monitor :publish do
      puts "Received on #{channel}: #{inspect}"
    end
  end
end
