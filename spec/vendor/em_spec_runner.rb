class EMSpecRunner
  module Mixin
    def self.included(base)
      base.extend(ClassMethods)
      base.delegate :finish, :finish_in, :deferred_finish,
        to: :@runner
    end

    def run(&block)
      @runner = EMSpecRunner.new
      @runner.run(&block)
    end

    def published_messages
      EMSpecRunner::FakePublisher.published_messages
    end

    def published_advances
      published_messages.select{|m| m[0] == '/room_events/advance'}
    end

    def last_published_round
      json = published_advances.last[1]
      json ? Hashie::Mash.new(JSON.parse(json)) : nil
    end

    module ClassMethods
      def em_around
        around(:each) do |example|
          run do
            example.run
          end
        end
      end
    end
  end

  module FakePublisher
    class << self
      def publish(*args) #channel, payload, [options]
        published_messages << args
      end

      def published_messages
        @published_messages ||= []
      end

      def reset
        @published_messages = nil
      end
    end
  end

  def run(&block)
    fail "already ran!" if @running
    @explicit_finish = false
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN

    old_em = EM
    Object.send(:remove_const, :EM)
    Object.const_set(:EM, MockEM::MockEM.new(@logger, Timecop))
    old_pub = RoomEventsController
    Object.send(:remove_const, :RoomEventsController)
    Object.const_set(:RoomEventsController, EMSpecRunner::FakePublisher)
    begin
      EMSpecRunner::FakePublisher.reset
      @running = true
      EM.run do
        block.call(self)
        finish if !@explicit_finish
      end
    ensure
      Object.send(:remove_const, :EM)
      Object.const_set(:EM, old_em)
      Object.send(:remove_const, :RoomEventsController)
      Object.const_set(:RoomEventsController, old_pub)
      Timecop.return
    end
  end

  def finish(&block)
    @explicit_finish = true
    EM.next_tick do
      block.call if block
      EM.stop
    end
  end

  #TODO: this currently blocks tests until it finishes in realtime :'(
  def finish_in(seconds, &block)
    @explicit_finish = true
    EM.add_timer(seconds) do
      block.call if block
      EM.stop
    end
  end

  #NB: This could cause the spec to hang, don't use this
  # unless you're certain it will eventually stop
  def deferred_finish
     @explicit_finish = true
  end
end
