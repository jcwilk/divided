//= require player_pool
//= require player_renderer

describe "Player Pool", () ->
  uuid = 'some_uuid'
  options = null
  pp = null

  beforeEach () ->
    options = {
      scaler: {
        xPosToX: (x,y) -> [x,y],
        yPosToY: (x,y) -> [x,y],
        scale: 1
      }
      extConfig: {animationDelay: 100}
      game: {
        add: {
          group: () -> "new_group"
        }
      }
      souls: []
      loadingText: {}
      directingPlayerUuid: uuid
      onDirectingPlayerDeath: jasmine.createSpy('onDirectingPlayerDeath')
    }
    pp = window.divided.playerPool(options)
    spyOn(pp.renderer, prop) for own prop, val of pp.renderer

  describe "Round related side effects", () ->
    it "set the player to be choosing", () ->
      pp.nextRound (r) ->
        r.register(uuid).at(2,3)
      expect(pp.renderer.markAsChoosing).toHaveBeenCalledWith(uuid)

    it "resets all the players to waiting", () ->
      pp.nextRound (r) ->
        r.register(uuid).at(2,3)
      expect(pp.renderer.markAllWaiting).toHaveBeenCalled()

    describe "when registering a player twice", () ->
      it "override redundancies than behave duplicatively", () ->
        pp.nextRound (r) ->
          r.register(uuid).at(2,3)
          r.register(uuid).at(2,3)
        expect(pp.renderer.markAsChoosing.calls.count()).toEqual(1)
        expect(pp.renderer.newWaitingDoom.calls.count()).toEqual(1)
        expect(pp.renderer.moveSprite).not.toHaveBeenCalled()

      it "permit a kill and a move and does not mark as choosing", () ->
        pp.nextRound (r) ->
          r.register(uuid).at(2,3).kill()
          r.register(uuid).at(3,3).kill()
        expect(pp.renderer.markAsChoosing).not.toHaveBeenCalled()
        expect(pp.renderer.newWaitingDoom.calls.count()).toEqual(1)
        expect(pp.renderer.newWaitingDoom).toHaveBeenCalledWith(3,3,uuid)
        expect(pp.renderer.moveSprite).not.toHaveBeenCalled()
        expect(pp.renderer.killSprite.calls.count()).toEqual(1)

      it "resets all the players to waiting only once", () ->
        pp.nextRound (r) ->
          r.register(uuid).at(2,3)
          r.register(uuid).at(2,3)
        expect(pp.renderer.markAllWaiting.calls.count()).toEqual(1)

  describe "Registering a player", () ->
    describe "for a new player", () ->
      it "makes a new player sprite at the specified location", () ->
        pp.nextRound (r) ->
          r.register(uuid).at(2,3)
        expect(pp.renderer.newWaitingDoom).toHaveBeenCalledWith(2,3,uuid)

      it "does not try to move an existing player", () ->
        pp.nextRound (r) ->
          r.register(uuid).at(2,3)
        expect(pp.renderer.moveSprite).not.toHaveBeenCalled()

    describe "for an existing player", () ->
      sprite = 'some_sprite'

      beforeEach () ->
        pp.renderer.isRenderingPlayer.and.returnValue(true)

      it "moves the player to the specified location", () ->
        pp.nextRound (r) ->
          r.register(uuid).at(2,3)
        expect(pp.renderer.moveSprite).toHaveBeenCalledWith(uuid,[2,3])

      it "does not create a new player", () ->
        pp.nextRound (r) ->
          r.register(uuid).at(2,3)
        expect(pp.renderer.newWaitingDoom).not.toHaveBeenCalled()

  describe "Killing a player", () ->
    beforeEach () ->
      pp.renderer.isRenderingPlayer.and.returnValue(true)

    it "renders a death for the uuid", () ->
      pp.nextRound (r) ->
        r.register(uuid).at(2,3).kill()
      expect(pp.renderer.killSprite).toHaveBeenCalledWith(uuid)

    it "does not mark as choosing", () ->
      pp.nextRound (r) ->
        r.register(uuid).at(2,3).kill()
      expect(pp.renderer.markAsChoosing).not.toHaveBeenCalled()

    describe "when the player moves at the same time", () ->
      it "moves the player", ->
        pp.nextRound (r) ->
          r.register(uuid).at(4,4).kill()
        expect(pp.renderer.moveSprite).toHaveBeenCalledWith(uuid,[4,4])

      it "still kills the player", ->
        pp.nextRound (r) ->
          r.register(uuid).at(4,4).kill()
        expect(pp.renderer.killSprite).toHaveBeenCalledWith(uuid)

      it "still does not mark as choosing", ->
        pp.nextRound (r) ->
          r.register(uuid).at(4,4).kill()
        expect(pp.renderer.markAsChoosing).not.toHaveBeenCalled()

    describe "when it's the directing player", () ->
      it "calls the onDirectingPlayerDeath callback", ->
        pp.nextRound (r) ->
          r.register(uuid).at(2,3).kill()
        expect(options.onDirectingPlayerDeath).toHaveBeenCalled()

    describe "when it's not the directing player", () ->
      beforeEach ->
        pp.nextRound (r) ->
          r.register('other_uuid').at(0,1)

      it "does not call the onDirectingPlayerDeath callback", () ->
        pp.nextRound (r) ->
          r.register('other_uuid').at(0,1).kill()
        expect(options.onDirectingPlayerDeath).not.toHaveBeenCalled()
