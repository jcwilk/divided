window.divided?= {}
selectionOverlay = (options) ->
  {remoteScaler,scaler,extConfig,game} = options

  {xPosToX,yPosToY,xPosToUnscaledX,yPosToUnscaledY,xToXPos,yToYPos} = scaler

  activeGlows = []
  glowLayer = game.add.group()
  texts = game.add.group()

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
    x = xPosToUnscaledX(xPos-0.5)
    y = yPosToUnscaledY(yPos-0.5)
    glow = obj.getGlow(x,y)

    action = rotation[0]

    if action == 'attack'
      glow.frame = 4
    else
      glow.frame = 0
    glow.apply()

    text = getText(action.toUpperCase(), xPos, yPos)

    glow.fadeAndKill = () ->
      glow.kill()
      text.kill()
    return glow

  mm = window.divided.moveMatrix()

  deferredSelection = null
  lastMoves = null

  game.input.onUp.add (e) ->
    xPos = xToXPos(e.x)
    yPos = yToYPos(e.y)
    at = mm.at(xPos,yPos)
    if at.any()
      obj.clearGlows()
      url = at.moves[Object.keys(at.moves)[0]]

      deferredSelection.resolve(url)
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

  obj = {
    at: (x,y) ->
      mm.at(x,y)
    getGlow: (x,y) ->
      g = remoteScaler.getSprite('rgb_glow', x: x, y: y)
      g.groupWith(glowLayer)
      activeGlows.push(g)
      g
    clearGlows: () ->
      $.each activeGlows, (i, glow) ->
        glow.fadeAndKill()
      activeGlows = []
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
      $.each mm.all, (i,at) ->
        glow = glowForActionsAtPos(Object.keys(at.moves),at.x,at.y)
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
