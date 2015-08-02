//= require remote_scaler

describe "Remote Scaler", ->
  game = null
  rs = null
  sprites = null

  finishLoading = ->
    game.load.onLoadComplete.call()

  beforeEach ->
    sprites = []
    onLoadCompleteCallbacks = []
    game = {
      load: {
        image: ->
        start: ->
        onLoadComplete: {
          call: ->
            $.each(onLoadCompleteCallbacks, (i,e) -> e())
            onLoadCompleteCallbacks = []
          addOnce: (cb) ->
            onLoadCompleteCallbacks.push(cb)
        }
      }
      add: {
        sprite: (x,y,label) ->
          newS = {
            alive: true
            x: x
            y: y
            label: label
            kill: -> newS.alive = false
            reset: (x,y) ->
              newS.alive = true
              newS.x = x
              newS.y = y
          }
          sprites.push newS
          newS
      }
    }
    rs = window.divided.remoteScaler(
      game: game
    )
    rs.registerPaths(
      apple: {
        x2: '/assets/apple.x2.gif'
        x4: '/assets/apple.x4.gif'
      }
    )

  it "returns an object", ->
    expect(rs).toEqual(jasmine.any(Object))

  describe 'setScale', ->
    it 'loads the resources for that scale', ->
      spyOn(game.load, 'image')
      rs.setScale(4, ->)
      expect(game.load.image).toHaveBeenCalledWith('apple.x4','/assets/apple.x4.gif')

    it 'calls the callback when the loading is complete', ->
      onFinish = jasmine.createSpy('onFinish')
      rs.setScale(4, onFinish)
      expect(onFinish).not.toHaveBeenCalled()
      finishLoading()
      expect(onFinish).toHaveBeenCalled()

    describe 'when switching to a second scale', ->
      beforeEach ->
        rs.setScale(2, ->)
        finishLoading()
        rs.getSprite('apple', x: 10, y: 10)

      it 'immediately kills the old sprite', ->
        spyOn(sprites[0],'kill')
        rs.setScale(4, ->)
        expect(sprites[0].kill).toHaveBeenCalled()

      it 'adds a new matching sprite of the new scale on complete', ->
        rs.setScale(4, ->)
        expect(sprites[1]).toBeUndefined()
        finishLoading()
        expect(sprites[1].x).toEqual(40)
        expect(sprites[1].y).toEqual(40)

    describe 'when returning to a previous scale', ->
      beforeEach ->
        rs.setScale(2, ->)
        finishLoading()
        rs.getSprite('apple', x: 10, y: 10)
        rs.setScale(4, ->)
        finishLoading()

      it 'does not fetch the assets again', ->
        spyOn(game.load, 'image')
        rs.setScale(2, ->)
        expect(game.load.image).not.toHaveBeenCalled()

      it 'immediately kills the new sprite', ->
        spyOn(sprites[1],'kill')
        rs.setScale(2, ->)
        expect(sprites[1].kill).toHaveBeenCalled()

      it 'does not create a new sprite', ->
        oldLength = sprites.length
        rs.setScale(2, ->)
        finishLoading()
        expect(sprites.length).toEqual(oldLength)

      it 'does not reset the new sprite', ->
        spyOn(sprites[1],'reset')
        rs.setScale(2, ->)
        finishLoading()
        expect(sprites[1].reset).not.toHaveBeenCalled()

      it 'immediately resets the old sprite', ->
        spyOn(sprites[0],'reset')
        rs.setScale(2, ->)
        expect(sprites[0].reset).toHaveBeenCalled()

    describe 'when switching to a second new scale before the first rescale has completed', ->
      firstCb = -> cbContainer.push('first')
      secondCb = -> cbContainer.push('second')
      cbContainer = null

      beforeEach ->
        cbContainer = []
        rs.setScale(2, firstCb)
        rs.getSprite('apple', x: 10, y: 10)
        rs.setScale(4, secondCb)

      it 'calls both callbacks at once, in order, on complete', ->
        expect(cbContainer).toEqual([])
        finishLoading()
        expect(cbContainer).toEqual(['first','second'])

      it 'draws the sprite only for the last scale', ->
        finishLoading()
        expect($.grep(sprites, (s) -> s.label == 'apple.x4').length).toEqual(1)
        expect($.grep(sprites, (s) -> s.label == 'apple.x2').length).toEqual(0)

    describe 'when returning to a previously rendered scale before a new scale has completed', ->
      sprite = null

      beforeEach ->
        rs.setScale(2, ->)
        finishLoading()
        sprite = rs.getSprite('apple', x: 10, y: 10).sprite
        rs.setScale(4, ->)

      it 'renders the sprite immediately', ->
        spyOn(sprite,'reset')
        rs.setScale(2, ->)
        expect(sprite.reset).toHaveBeenCalled()

      it 'does not reset or create any sprites on completion', ->
        rs.setScale(2, ->)
        spyOn(sprite,'reset')
        oldLength = sprites.length
        finishLoading()
        expect(sprite.reset).not.toHaveBeenCalled()
        expect(sprites.length).toEqual(oldLength)

    describe 'when returning to a previously rendered scale and then returning to a still loading scale', ->
      beforeEach ->
        rs.setScale(2, ->)
        finishLoading()
        rs.getSprite('apple', x: 10, y: 10)
        rs.setScale(4, ->)
        rs.setScale(2, ->)

      it 'kills all sprites', ->
        expect($.grep(sprites, (s) -> s.alive).length).toBeGreaterThan(0)
        rs.setScale(4, ->)
        expect($.grep(sprites, (s) -> s.alive).length).toEqual(0)

      it 'renders the sprite for the new scale on complete', ->
        rs.setScale(4, ->)
        expect($.grep(sprites, (s) -> s.alive).length).toEqual(0)
        finishLoading()
        aliveSprites = $.grep(sprites, (s) -> s.alive)
        expect(aliveSprites.length).toEqual(1)
        expect(aliveSprites[0].label).toEqual('apple.x4')

  describe 'scaledSprite.kill', ->
    scaledSprite = null
    sprite = null

    beforeEach ->
      rs.setScale(2, ->)
      finishLoading()
      scaledSprite = rs.getSprite('apple', x: 0, y: 0)
      sprite = scaledSprite.sprite

    it 'kills the associated sprite', ->
      spyOn(sprite, 'kill')
      scaledSprite.kill()
      expect(sprite.kill).toHaveBeenCalled()

    it 'prevents an associated sprite from getting drawn during a rescale', ->
      scaledSprite.kill()
      spyOn(sprite, 'reset')
      oldLength = sprites.length
      rs.setScale(4, ->)
      finishLoading()
      expect(sprite.reset).not.toHaveBeenCalled()
      expect(sprites.length).toEqual(oldLength)

  describe 'reset', ->
    scaledSprite = null
    sprite = null

    beforeEach ->
      rs.setScale(2, ->)
      finishLoading()
      scaledSprite = rs.getSprite('apple', x: 10, y: 10)
      sprite = scaledSprite.sprite
      scaledSprite.kill()

    it 'does not create a new sprite', ->
      oldLength = sprites.length
      scaledSprite.reset()
      expect(sprites.length).toEqual(oldLength)

    it 'immediately resets an old sprite', ->
      spyOn(sprite, 'reset')
      scaledSprite.reset()
      expect(sprite.reset).toHaveBeenCalled()

    describe 'when in the middle of a rescale to a new scale', ->
      beforeEach ->
        rs.setScale(4, ->)

      it 'adds a new matching sprite of the new scale on complete', ->
        scaledSprite.reset()
        expect(sprites[1]).toBeUndefined()
        finishLoading()
        expect(sprites[1].x).toEqual(40)
        expect(sprites[1].y).toEqual(40)