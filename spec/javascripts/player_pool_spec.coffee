//= require player_pool
//= require player_renderer

describe "Player Pool", () ->
  uuid = 'some_uuid'
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
    playerPosMap: {}
  }
  pp = null

  beforeEach () ->
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
        pp.renderer.newWaitingDoom.and.returnValue(sprite)
        pp.register(uuid).at(0,0)
        pp.renderer.newWaitingDoom.calls.reset()
        pp.renderer.newWaitingDoom.and.stub()

      it "moves the player to the specified location", () ->
        pp.register(uuid).at(2,3)
        expect(pp.renderer.moveSprite).toHaveBeenCalledWith(sprite,[2,3])

      it "does not create a new player", () ->
        pp.register(uuid).at(2,3)
        expect(pp.renderer.newWaitingDoom).not.toHaveBeenCalled()

