window.MoveMatrix = () ->
  mat = {}
  all = []
  at = (x,y) ->
    key = "#{x},#{y}"
    mat[key] ?= {}

    {
      addMoves: (newMoves) ->
        if Object.keys(newMoves).length > 0 && Object.keys(mat[key]).length == 0
          all.push at(x,y)
        $.extend(mat[key], newMoves)
      moves: mat[key]
      x: x
      y: y
    }

  {
    all: all
    at: at
  }
