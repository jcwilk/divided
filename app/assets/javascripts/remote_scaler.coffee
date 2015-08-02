window.divided?= {}
window.divided.remoteScaler = (options) ->
  {game} = options

  #keep this only alive so dead scaledSprites get collected
  aliveScaledSprites = []

  registeredPaths = {}
  scale = null
  loadedScales = []
  spritesMap = {}
  currentSprites = []
  isRescaling = false
  isLoading = false
  rescaleCallbacks = {}

  clearAllLiving = ->
    eachLivingScaledSprite (scaledSprite) ->
      scaledSprite.clear()

  drawAllLiving = ->
    eachLivingScaledSprite (scaledSprite) ->
      scaledSprite.draw()

  getFirstDeadCurrentSprite = ->
    $.grep(currentSprites, (el)-> !el.alive)[0]

  eachLivingScaledSprite = (cb) ->
    $.each aliveScaledSprites, (i, scaledSprite) ->
      cb(scaledSprite)

  checkScaleLoaded = (s) ->
    $.inArray(s,loadedScales) >= 0

  onLoadComplete = () ->
    isLoading = false
    $.each rescaleCallbacks, (k,v) ->
      cbScale = parseInt(k)
      loadedScales.push(cbScale)
      if cbScale == scale
        isRescaling = false
        drawAllLiving()
      v()
    rescaleCallbacks = {}

  obj = {
    registerPaths: (newPaths) -> $.extend(registeredPaths,newPaths)
    setScale: (s,cb) ->
      scale = s
      cb?= ->

      clearAllLiving()
      spritesMap[scale]?= []
      currentSprites = spritesMap[scale]

      if checkScaleLoaded(scale)
        isRescaling = false
        drawAllLiving()
        cb()
      else if !rescaleCallbacks[scale]?
        $.each(registeredPaths, (label,sizeMap) ->
          game.load.image(label+'.x'+scale,sizeMap['x'+scale])
        )
        rescaleCallbacks[scale] = cb
        if !isLoading
          isLoading = true
          isRescaling = true
          game.load.onLoadComplete.addOnce(onLoadComplete)
          game.load.start()

    getSprite: (label,options) ->
      {x,y} = options

      scaledSprite = {
        draw: ->
          return if isRescaling

          if firstDead = getFirstDeadCurrentSprite()
            scaledSprite.sprite = firstDead
            firstDead.reset(x*scale,y*scale)
          else
            scaledSprite.sprite = game.add.sprite(x*scale,y*scale,label+'.x'+scale)
            currentSprites.push(scaledSprite.sprite)
        clear: ->
          return if !scaledSprite.sprite?

          scaledSprite.sprite.kill()
          scaledSprite.sprite = null
        kill: ->
          scaledSprite.clear()
          scaledSprite.alive = false
          aliveIndex = aliveScaledSprites.indexOf(scaledSprite)
          aliveScaledSprites.splice(aliveIndex,1)
        reset: ->
          scaledSprite.alive = true
          aliveScaledSprites.push(scaledSprite)

          scaledSprite.draw()
      }

      scaledSprite.reset()

      scaledSprite
  }