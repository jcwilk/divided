window.MoveMatrix = () ->
  mat = {}
  {
    at: (x,y) ->
      key = "#{x},#{y}"
      mat[key] ?= {}
      {
        addMoves: (newMoves) ->
          $.extend(mat[key], newMoves)
        moves: mat[key]
      }
  }
