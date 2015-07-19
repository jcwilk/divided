window.divided?= {}
selectionOverlay = (options) ->
  {scaler,extConfig,game} = options

  {xPosToX,yPosToY} = scaler

  activeGlows = game.add.group()
  activeGlows.alpha = 1
  texts = game.add.group()
  glows = []

  debug = () ->
    console.log("activeGlows: "+activeGlows.length+" living: "+activeGlows.countLiving())
    console.log("texts: "+texts.length+" living: "+texts.countLiving())
    console.log("glows: "+glows.length+" living: "+$.grep(glows,((gl) -> gl.alive)).length)

  getText = (content,xPos,yPos) ->
    x = xPosToX(xPos)
    y = yPosToY(yPos)
    if t = texts.getFirstDead()
      t.reset(x,y)
      t.setText(content)
    else
      t = game.add.text(x,y,content, {
        fill:            "#ffffff"
        align:           "center"
        stroke:          '#000000'
        strokeThickness: 2
      })
      t.font = 'Arial'
      t.fontWeight = 'bold'
      t.anchor.set(0.5)
      t.angle = 25
      texts.add(t)
    t.fontSize = 4*scaler.scale
    t

  glowForActionsAtPos = (rotation,xPos,yPos) ->
    x = xPosToX(xPos)
    y = yPosToY(yPos)
    glow = obj.getGlow(x,y)

    action = rotation[0]

    if action == 'attack'
      glow.frame = 4
    else
      glow.frame = 0

    text = getText(action.toUpperCase(), xPos, yPos)

    glow.fadeAndKill = () ->
      glow.events.onInputUp.removeAll()
      glow.kill()
      text.kill()
    return glow

  mm = window.divided.moveMatrix()

  deferredSelection = null
  lastMoves = null

  obj = {
    at: (x,y) ->
      mm.at(x,y)
    getGlow: (x,y) ->
      g = $.grep(glows,((gl) -> !gl.alive))[0]
      if g
        g.reset(x,y)
        g.alpha = 1
      else
        g = game.add.sprite(x,y,'rgb_glow')
        glows.push(g)
        g.anchor.set(0.5)
        g.smoothed = false
      g.scale.set(scaler.scale)
      activeGlows.add(g)
      g
    clearGlows: () ->
      activeGlows.callAllExists('fadeAndKill',true)
      activeGlows.removeAll()
    reset: () ->
      mm = window.divided.moveMatrix()
      obj.clearGlows()
      if deferredSelection?
        deferredSelection.reject(new Error("Resetting!"))
        deferredSelection = null
      lastMoves = null
    redraw: () ->
      obj.clearGlows()
      if lastMoves?
        obj.drawRemoteMoves(lastMoves)
    drawMatrixGlows: () ->
      currentDefer = deferredSelection
      $.each mm.all, (i,at) ->
        glow = glowForActionsAtPos(Object.keys(at.moves),at.x,at.y)
        glow.inputEnabled = true
        glow.events.onInputUp.add (g) ->
          obj.clearGlows()

          url = at.moves[Object.keys(at.moves)[0]]

          currentDefer.resolve(url)
          $.ajax(url, {
            type: "POST",
            statusCode: {
              422: (response) ->
                #TODO: move this up out of the POST
                #game.add.tween(player).to({x: player.x-5},50,Phaser.Easing.Default,true,0,5,true);
              500: (response) ->
                #not really relevant anymore
                #location.reload()
              403: (response) ->
                #TODO: auth lol
                #location.reload()
            }
          })
    selectionForParticipant: (participant) ->
      obj.reset()

      promise = participant.links['dv:moves'].fetch().then((moves) ->
        #TODO: this could have unpredictable results if called a second time before it finishes
        lastMoves = moves
        if deferredSelection?
          deferredSelection.reject(new Error("No selection!"))
        deferredSelection = Q.defer()

        obj.drawRemoteMoves(lastMoves)

        return deferredSelection.promise
      ).catch (error) ->
        console.log("Failed promise!")
        console.log(error)
        console.log(error.stack)
      return promise
    drawRemoteMoves: (moves) ->
      $.each moves.embedded.moves, (i,move) ->
        newMoves = {}
        newMoves[move.props.action] = move.url()
        obj.at(move.props.x,move.props.y).addMoves(newMoves);

      obj.drawMatrixGlows()
  }
window.divided.selectionOverlay = selectionOverlay
