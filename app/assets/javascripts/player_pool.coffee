window.divided?= {}
window.divided.playerPool = (options) ->
  {
    xPosToX,
    yPosToY,
    game,
    souls,
    loadingText,
    directing_player_uuid,
    playerPosMap,
    extConfig
  } = options

  spritesByUuid = {}

  obj = {
    renderer: window.divided.playerRenderer({
      xPosToX:               xPosToX,
      yPosToY:               yPosToY,
      game:                  game,
      souls:                 souls,
      loadingText:           loadingText,
      directing_player_uuid: directing_player_uuid,
      playerPosMap:          playerPosMap,
      extConfig:             extConfig
    })
    register: (uuid) ->
      {
        at: (x,y) ->
          if spritesByUuid[uuid]?
            obj.renderer.moveSprite(spritesByUuid[uuid],[x,y])
          else
            spritesByUuid[uuid] = obj.renderer.newWaitingDoom(x,y,uuid)
      }
  }
