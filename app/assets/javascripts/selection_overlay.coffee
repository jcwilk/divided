window.divided?= {}
selectionOverlay = (options) ->
  {xPosToX,yPosToY,extConfig,game} = options

  getText = (content,xPos,yPos) ->
    x = xPosToX(xPos)
    y = yPosToY(yPos)
    t = obj.game.add.text(x,y,content, {
      fill:            "#ffffff"
      align:           "center"
      stroke:          '#000000'
      strokeThickness: 2
    })
    t.font = 'Arial'
    t.fontWeight = 'bold'
    t.fontSize = 15
    t.anchor.set(0.5)
    t.angle = 25
    #text.alpha = 0.5;
    obj.popups.add(t)
    t

  glowForActionsAtPos = (rotation,xPos,yPos) ->
    x = xPosToX(xPos)
    y = yPosToY(yPos)
    glow = obj.getGlow(x,y)
    blink = null

    tweenForIndex = (rotationIndex) ->
      action = rotation[rotationIndex % rotation.length]

      if action == 'attack'
        glow.frame = 0
      else
        glow.frame = 1

      text = getText(action.toUpperCase(), xPos, yPos)

      blink = obj.game.add.tween(glow).to({alpha: 0.4},extConfig.blinkDelay/rotation.length,Phaser.Easing.Circular.Out,true)
      blink.onComplete.add () ->
        blink = obj.game.add.tween(glow).to({alpha: 0.0},extConfig.blinkDelay/rotation.length,Phaser.Easing.Circular.In,true)
        blink.onComplete.add () ->
          text.destroy()
          tweenForIndex(rotationIndex+1)
    tweenForIndex(0)

    isDying = false
    glow.fadeAndKill = () ->
      if isDying
        return
      isDying = true

      blink.stop()
      glow.events.onInputUp.removeAll()
      obj.game.add.tween(glow).to({alpha: 0.0},extConfig.blinkDelay*(glow.alpha/0.4),Phaser.Easing.Quadratic.InOut,true,0)
      .onComplete.add () ->
        glow.kill()
    return glow

  mm = window.divided.moveMatrix()

  deferredSelection = null

  obj = {
    game: game
    glows: game.add.group()
    popups: game.add.group()
    at: (x,y) ->
      mm.at(x,y)
    setGame: (game) ->
      obj.game = game
      obj
    getGlow: (x,y) ->
      g = obj.glows.getFirstDead()
      if g
        g.reset(x,y)
      else
        g = obj.glows.create(x,y,'rgb_glow')
      g.anchor.set(0.5)
      g.alpha = 0
      g
    clearGlows: () ->
      obj.glows.callAllExists('fadeAndKill',true)
      obj.popups.destroy(true,true)
    reset: () ->
      mm = window.divided.moveMatrix()
      obj.clearGlows()
      deferredSelection = null
    drawMatrixGlows: () ->
      console.log(mm.all)
      if deferredSelection?
        deferredSelection.reject(new Error("No selection!"))
      currentDefer = Q.defer()
      deferredSelection = currentDefer
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
      return currentDefer
    loadGlowsForParticipant: (participant) ->
      obj.reset()
      promise = (participant.links['dv:moves'].fetch().then((moves) ->
        $.each moves.embedded.moves, (i,move) ->
          newMoves = {}
          newMoves[move.props.action] = move.url()
          obj.at(move.props.x,move.props.y).addMoves(newMoves);

        return obj.drawMatrixGlows().promise
      ).catch (error) ->
        console.log("Failed promise!")
        console.log(error)
        console.log(error.stack)
      )
      return promise
  }
window.divided.selectionOverlay = selectionOverlay
