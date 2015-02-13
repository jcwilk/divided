window.MoveMatrix = () ->
  mat = {}
  {
    at: (x,y) ->
      key = "#{x},#{y}"
      {
        addMove: (link) ->
          mat[key] = {attack: link}
        moves: mat[key] || {}
      }
  }
