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
    registerPaths: (newPaths) ->
      $.extend(registeredPaths,newPaths)
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
        $.each(registeredPaths, (label,sizeAttrs) ->
          switch sizeAttrs.type
            when 'spritesheet'
              game.load.spritesheet(
                label+'.x'+scale,
                sizeAttrs.scales[scale-1],
                sizeAttrs.width*scale,
                sizeAttrs.height*scale,
                sizeAttrs.count
              )
            when 'image'
              game.load.image(
                label+'.x'+scale,
                sizeAttrs.scales[scale-1]
              )
        )
        rescaleCallbacks[scale] = cb
        if !isLoading
          isLoading = true
          isRescaling = true
          game.load.onLoadComplete.addOnce(onLoadComplete)
          game.load.start()

    getSprite: (label,options) ->
      {x,y} = options

      children = []

      scaledSprite = {
        draw: ->
          return if isRescaling || scaledSprite.sprite?

          if firstDead = getFirstDeadCurrentSprite()
            scaledSprite.sprite = firstDead
            firstDead.reset(x*scale,y*scale)
          else
            scaledSprite.sprite = game.add.sprite(x*scale,y*scale,label+'.x'+scale)
            currentSprites.push(scaledSprite.sprite)

          $.each children, (i, child) ->
            child.draw()
            scaledSprite.sprite.addChild(child.sprite)
        clear: ->
          return if !scaledSprite.sprite?

          scaledSprite.sprite.removeChildren()
          scaledSprite.sprite.kill()
          scaledSprite.sprite = null
        kill: ->
          return if !scaledSprite.alive

          scaledSprite.clear()
          $.each children, (i, child) ->
            child.kill()
          scaledSprite.alive = false
          aliveIndex = aliveScaledSprites.indexOf(scaledSprite)
          aliveScaledSprites.splice(aliveIndex,1)
        reset: ->
          return if scaledSprite.alive

          scaledSprite.alive = true
          aliveScaledSprites.push(scaledSprite)

          scaledSprite.draw()
        addChild: (child) ->
          children.push(child)
          if scaledSprite.sprite?
            child.draw()
            scaledSprite.sprite.addChild(child.sprite)

      }

      scaledSprite.reset()

      scaledSprite
  }