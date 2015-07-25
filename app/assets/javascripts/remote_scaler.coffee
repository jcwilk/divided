window.divided?= {}
window.divided.remoteScaler = (options) ->
  {game} = options

  registeredPaths = {}
  scale = null
  currentSprites = []
  onLoadComplete = null

  clearAll = ->
    $.each currentSprites, (i,scaledSprite) ->
      scaledSprite.kill()

  drawAll = ->
    $.each currentSprites, (i,scaledSprite) ->
      scaledSprite.draw()

  obj = {
    registerPaths: (newPaths) -> $.extend(registeredPaths,newPaths)
    setScale: (s,cb) ->
      scale = s
      $.each(registeredPaths, (label,sizeMap) ->
        game.load.image(label+'.x'+scale,sizeMap['x'+scale])
      )
      game.load.onLoadComplete.add ->
        #TODO: this would behave oddly if setScale calls stacked up
        game.load.onLoadComplete.removeAll()
        drawAll()
        cb()

      game.load.start()
      clearAll()

    getSprite: (label,options) ->
      {x,y} = options

      scaledSprite = {
        draw: ->
          scaledSprite.sprite = game.add.sprite(x*scale,y*scale,label+'.x'+scale)
        kill: ->
          scaledSprite.sprite.kill()
      }

      scaledSprite.draw()

      currentSprites.push(scaledSprite)
      scaledSprite
  }