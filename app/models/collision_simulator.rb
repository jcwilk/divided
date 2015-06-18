class CollisionSimulator
  VERTICAL = :vertical #slope going straight up and down
  RESOLUTION = 7 #how many time slices to check for collisions

  def initialize
    @participants = []
  end

  def add_participant(initial:,final:,id:)
    if initial[0] == final[0]
      slope = VERTICAL
      slice_size = (final[1] - initial[1]).to_f/RESOLUTION
    else
      slope = (final[1] - initial[1]).to_f/(final[0] - initial[0])
      slice_size = (final[0] - initial[0]).to_f/RESOLUTION
    end
    @participants << {initial: initial, slope: slope, slice_size: slice_size, id: id}
  end

  def collisions
    found = []
    moving = @participants.select {|p| p[:slice_size] != 0 }
    stationary_map = {}
    (@participants - moving).each do |p|
      stationary_map[p[:id]] = p[:initial]
    end

    (0..RESOLUTION).each do |slice|
      current = stationary_map.dup
      moving.each do |m|
        if m[:slope] == VERTICAL
          x = m[:initial][0]
          y = m[:initial][1]+m[:slice_size]*slice
        else
          x = m[:initial][0]+m[:slice_size]*slice
          y = m[:initial][1]+m[:slope]*m[:slice_size]*slice
        end
        current[m[:id]] = [x,y]
      end

      moving.each do |m|
        others = current.dup
        x,y = others.delete(m[:id])
        collides = []
        others.each do |id, (ox,oy)|
          collides << id if (x-ox).abs <= 1 && (y-oy).abs <= 1
        end
        if collides.present?
          collides+=[m[:id]]
          collides.each do |c|
            if mover = moving.find {|m| m[:id] == c }
              found << {id: c, final: current[c].map(&:round)}
              moving.delete(mover)
              stationary_map[c] = current[c]
            end
          end
        end
      end
    end

    found
  end
end
