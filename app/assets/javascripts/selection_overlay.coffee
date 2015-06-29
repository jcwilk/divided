window.divided?= {}
selectionOverlay = (options) ->
  {scaler,extConfig,game} = options

  {xPosToX,yPosToY} = scaler

  activeGlows = game.add.group()
  activeGlows.alpha = 0
  blink = null
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
      t.fontSize = 4*scaler.scale
      t.anchor.set(0.5)
      t.angle = 25
      texts.add(t)
    t

  glowForActionsAtPos = (rotation,xPos,yPos) ->
    x = xPosToX(xPos)
    y = yPosToY(yPos)
    glow = obj.getGlow(x,y)
    text = null
    looping = true

    tweenForIndex = (rotationIndex) ->
      if !looping
        return

      action = rotation[rotationIndex % rotation.length]

      if action == 'attack'
        glow.frame = 0
      else
        glow.frame = 1

      if !text?
        text = getText(action.toUpperCase(), xPos, yPos)
      else
        if text.text != action.toUpperCase()
          text.setText(action.toUpperCase())

      if text.fontSize != 4*scaler.scale
          text.fontSize = 4*scaler.scale
      
      window.setTimeout((() -> tweenForIndex(rotationIndex+1)), extConfig.blinkDelay*2)
    tweenForIndex(0)

    glow.fadeAndKill = () ->
      if !looping
        return
      looping = false
      glow.events.onInputUp.removeAll()
      glow.kill()
      text.kill()
    return glow

  mm = window.divided.moveMatrix()

  deferredSelection = null
  lastParticipant = null

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
      g.scale.set(scaler.scale)
      activeGlows.add(g)
      g
    clearGlows: () ->
      activeGlows.callAllExists('fadeAndKill',true)
      activeGlows.removeAll()
      if blink?
        blink.stop()
    reset: () ->
      mm = window.divided.moveMatrix()
      obj.clearGlows()
      deferredSelection = null
      lastParticipant = null
    redraw: () ->
      if lastParticipant?
        p = lastParticipant
        obj.reset()
        obj.selectionForParticipant(p)
    drawMatrixGlows: () ->
      if deferredSelection?
        deferredSelection.reject(new Error("No selection!"))
      currentDefer = Q.defer()
      deferredSelection = currentDefer
      tweenLoop = () ->
        blink = game.add.tween(activeGlows).to({alpha: 0.6},extConfig.blinkDelay,Phaser.Easing.Circular.Out,true)
        blink.onComplete.add () ->
          blink = game.add.tween(activeGlows).to({alpha: 0.0},extConfig.blinkDelay,Phaser.Easing.Circular.In,true)
          blink.onComplete.add () ->
            tweenLoop()
      tweenLoop()
      $.each mm.all, (i,at) ->
        glow = glowForActionsAtPos(Object.keys(at.moves),at.x,at.y)
        glow.inputEnabled = true
        glow.events.onInputUp.add (g) ->
          obj.clearGlows()

          postToUrl = (u) ->
            currentDefer.resolve(u)
            $.ajax(u, {
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

          if Object.keys(at.moves).length == 1
            postToUrl(at.moves[Object.keys(at.moves)[0]])
          else
            offsets = [
              [+1,+1]
              [-1,+1]
              [+1,-1]
              [-1,-1]
            ]
            $.each at.moves, (name, url) ->
              offset = offsets.pop()
              subGlow = glowForActionsAtPos([name], at.x+offset[0], at.y+offset[1])
              subGlow.inputEnabled = true
              subGlow.events.onInputUp.add((t) ->
                obj.clearGlows()
                postToUrl(url)
              this)
      #debug()
      return currentDefer
    selectionForParticipant: (participant) ->
      obj.reset()
      lastParticipant = participant
      
      promise = participant.links['dv:moves'].fetch().then((moves) ->
        $.each moves.embedded.moves, (i,move) ->
          newMoves = {}
          newMoves[move.props.action] = move.url()
          obj.at(move.props.x,move.props.y).addMoves(newMoves);

        return obj.drawMatrixGlows().promise
      ).catch (error) ->
        console.log("Failed promise!")
        console.log(error)
        console.log(error.stack)
      return promise
  }
window.divided.selectionOverlay = selectionOverlay
