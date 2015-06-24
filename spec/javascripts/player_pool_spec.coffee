//= require player_pool
//= require player_renderer

describe "Player Pool", () ->
  uuid = 'some_uuid'
  options = null
  pp = null

  beforeEach () ->
    options = {
      xPosToX: (x,y) -> [x,y]
      yPosToY: (x,y) -> [x,y]
      extConfig: {animationDelay: 100}
      game: {
        add: {
          group: () -> "new_group"
        }
      }
      souls: []
      loadingText: {}
      directing_player_uuid: uuid
      onDirectingPlayerDeath: jasmine.createSpy('onDirectingPlayerDeath')
    }
    pp = window.divided.playerPool(options)
    spyOn(pp.renderer, prop) for own prop, val of pp.renderer

  describe "Registering a player", () ->
    describe "for a new player", () ->
      it "makes a new player sprite at the specified location", () ->
        pp.register(uuid).at(2,3)
        expect(pp.renderer.newWaitingDoom).toHaveBeenCalledWith(2,3,uuid)

    describe "for an existing player", () ->
      sprite = 'some_sprite'

      beforeEach () ->
        pp.renderer.isRenderingPlayer.and.returnValue(true)

      it "moves the player to the specified location", () ->
        pp.register(uuid).at(2,3)
        expect(pp.renderer.moveSprite).toHaveBeenCalledWith(uuid,[2,3])

      it "does not create a new player", () ->
        pp.register(uuid).at(2,3)
        expect(pp.renderer.newWaitingDoom).not.toHaveBeenCalled()

  describe "Killing a player", () ->
    beforeEach () ->
      pp.register(uuid).at(2,3)

    it "renders a death for the uuid", () ->
      pp.register(uuid).kill()
      expect(pp.renderer.killSprite).toHaveBeenCalledWith(uuid)

    it "sets them to waiting", () ->
      pp.register(uuid).kill()
      expect(pp.renderer.markAsWaiting).toHaveBeenCalledWith(uuid)

    describe "when it's the directing player", () ->
      it "calls the onDirectingPlayerDeath callback", ->
        pp.register(uuid).kill()
        expect(options.onDirectingPlayerDeath).toHaveBeenCalled()

    describe "when it's not the directing player", () ->
      beforeEach ->
        pp.register('other_uuid').at(0,1)

      it "does not call the onDirectingPlayerDeath callback", () ->
        pp.register('other_uuid').kill()
        expect(options.onDirectingPlayerDeath).not.toHaveBeenCalled()
