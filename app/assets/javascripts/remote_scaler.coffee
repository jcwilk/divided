window.divided?= {}
window.divided.remoteScaler = (options) ->
  {game} = options

  registeredPaths = {}
  scale = null
  allScaledSprites = []
  onLoadComplete = null
  loadedScales = []
  spritesMap = {}
  currentSprites = []

  clearAllLiving = ->
    eachLivingScaledSprite (scaledSprite) ->
      scaledSprite.clear()

  drawAllLiving = ->
    eachLivingScaledSprite (scaledSprite) ->
      scaledSprite.draw()

  getFirstDeadCurrentSprite = ->
    $.grep(currentSprites, (el)-> !el.alive)[0]

  eachLivingScaledSprite = (cb) ->
    $.each allScaledSprites, (i, scaledSprite) ->
      if scaledSprite.alive
        cb(scaledSprite)

  obj = {
    registerPaths: (newPaths) -> $.extend(registeredPaths,newPaths)
    setScale: (s,cb) ->
      scale = s

      onLoadComplete = ->
        drawAllLiving()
        cb()

      clearAllLiving()
      spritesMap[scale]?= []
      currentSprites = spritesMap[scale]

      if $.inArray(scale,loadedScales) == -1
        loadedScales.push(scale)
        $.each(registeredPaths, (label,sizeMap) ->
          game.load.image(label+'.x'+scale,sizeMap['x'+scale])
        )
        game.load.onLoadComplete.add ->
          #TODO: this would behave oddly if setScale calls stacked up
          game.load.onLoadComplete.removeAll()
          onLoadComplete()
        game.load.start()
      else
        onLoadComplete()

    getSprite: (label,options) ->
      {x,y} = options

      scaledSprite = {
        alive: true
        draw: ->
          if firstDead = getFirstDeadCurrentSprite()
            scaledSprite.sprite = firstDead
            firstDead.reset(x*scale,y*scale)
          else
            scaledSprite.sprite = game.add.sprite(x*scale,y*scale,label+'.x'+scale)
            currentSprites.push(scaledSprite.sprite)
        clear: ->
          scaledSprite.sprite.kill()
          scaledSprite.sprite = null
        kill: ->
          scaledSprite.clear()
          scaledSprite.alive = false

      }

      scaledSprite.draw()

      allScaledSprites.push(scaledSprite)
      scaledSprite
  }