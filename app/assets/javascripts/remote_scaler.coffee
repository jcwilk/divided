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
  isRescaling = false
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
    $.each allScaledSprites, (i, scaledSprite) ->
      return if !scaledSprite.alive

      cb(scaledSprite)

  checkScaleLoaded = (s) ->
    $.inArray(s,loadedScales) >= 0

  onLoadComplete = () ->
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
        if !isRescaling
          isRescaling = true
          game.load.onLoadComplete.addOnce(onLoadComplete)
          game.load.start()

    getSprite: (label,options) ->
      {x,y} = options

      scaledSprite = {
        alive: true
        draw: ->
          return if !scale? || isRescaling

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
        reset: ->
          scaledSprite.alive = true
          scaledSprite.draw()
      }

      scaledSprite.draw()

      allScaledSprites.push(scaledSprite)
      scaledSprite
  }