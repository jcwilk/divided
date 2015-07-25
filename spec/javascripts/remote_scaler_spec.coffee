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
          call: -> $.each(onLoadCompleteCallbacks, (i,e) -> e())
          add: (cb) -> onLoadCompleteCallbacks.push(cb)
          removeAll: -> onLoadCompleteCallbacks = []
        }
      }
      add: {
        sprite: (x,y,label) ->
          newS = {
            x: x,
            y: y,
            label: label,
            kill: ->
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
      rs.setScale(4)
      expect(game.load.image).toHaveBeenCalledWith('apple.x4','/assets/apple.x4.gif')

    it 'calls the callback when the loading is complete', ->
      onFinish = jasmine.createSpy('onFinish')
      rs.setScale(4, onFinish)
      expect(onFinish).not.toHaveBeenCalled()
      finishLoading()
      expect(onFinish).toHaveBeenCalled()

    describe 'with an already existing sprite from another scale', ->
      beforeEach ->
        rs.setScale(2, ->)
        finishLoading()
        rs.getSprite('apple', x: 10, y: 10)

      it 'immediately kills the old sprite', ->
        spyOn(sprites[0],'kill')
        rs.setScale(4, ->)
        expect(sprites[0].kill).toHaveBeenCalled()

      it 'adds a new matching sprite of the appropriate scale on complete', ->
        rs.setScale(4, ->)
        expect(sprites[1]).toBeUndefined()
        finishLoading()
        expect(sprites[1].x).toEqual(40)
        expect(sprites[1].y).toEqual(40)
