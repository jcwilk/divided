class RoomEventsController < FayeRails::Controller
  channel '/room_events/advance' do
    monitor :publish do
      puts "Received on #{channel}: #{inspect}"
    end
  end
  channel '/room_events/waiting' do
    monitor :publish do
      puts "Received on #{channel}: #{inspect}"
    end
  end
end
