window.divided?= {}
window.divided.moveMatrix = () ->
  mat = {}
  all = []
  at = (x,y) ->
    key = "#{x},#{y}"
    mat[key] ?= {}

    atObj = {
      addMoves: (newMoves) ->
        if Object.keys(newMoves).length > 0 && !atObj.any()
          all.push at(x,y)
        $.extend(mat[key], newMoves)
      any: ->
        Object.keys(mat[key]).length > 0
      moves: mat[key]
      x: x
      y: y
    }

  {
    all: all
    at: at
  }
