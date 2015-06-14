class GameRunner
  class FakeMethodProxy
    def initialize(&block)
      @block = block
    end

    def method_missing(name, *args)
      @block.call(name, *args)
    end
  end

  def initialize(spec, player_map)
    @spec = spec
    player_map.each do |player, pos|
      set_starting_move(*pos)
      Round.current_round.join(player)
    end
    @pending_rounds = []
    last_round = Round.current_round

    time_poller = Proc.new do
      if Round.current_round != last_round
        puts 'new_round'
        last_round = Round.current_round
        next_proc = @pending_rounds.shift
        if next_proc
          next_proc.call
        else
          in_spec do
            finish {}
          end
        end
      end
      EM.add_timer(1,&time_poller)
    end
    EM.next_tick(&time_poller)

    in_spec { deferred_finish }
  end

  def in_spec(&block)
    @spec.instance_eval(&block)
  end

  def set_starting_move(x,y)
    in_spec do
      allow_any_instance_of(Round).to receive(:get_starting_move).and_return([x,y])
    end
  end

  def next_round(&block)
    @pending_rounds << Proc.new do
      block.call(self)
    end
  end

  def find(player)
    in_spec do
      last_published_round.players[player.uuid]
    end
  end

  def choose(player)
    FakeMethodProxy.new do |name, x, y|
      in_spec do
        move = available_moves(player.uuid).find {|i| i.action == name.to_s && i.x == x && i.y == y }
        fail "No #{name} move found at #{[x,y].inspect}!" if move.nil?
        move.post
      end
    end
  end
end
