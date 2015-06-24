window.divided?= {}
window.divided.playerPool = (options) ->
  {
    xPosToX,
    yPosToY,
    game,
    souls,
    loadingText,
    directing_player_uuid,
    extConfig,
    onDirectingPlayerDeath
  } = options

  obj = {
    renderer: window.divided.playerRenderer({
      xPosToX:               xPosToX,
      yPosToY:               yPosToY,
      game:                  game,
      souls:                 souls,
      loadingText:           loadingText,
      directing_player_uuid: directing_player_uuid,
      extConfig:             extConfig
    })
    register: (uuid) ->
      reg = {
        at: (x,y) ->
          if obj.renderer.isRenderingPlayer(uuid)
            obj.renderer.moveSprite(uuid,[x,y])
          else
            obj.renderer.newWaitingDoom(x,y,uuid)
          reg
        kill: () ->
          obj.renderer.killSprite(uuid)
          obj.renderer.markAsWaiting(uuid)

          if uuid == directing_player_uuid
            onDirectingPlayerDeath()
      }
  }
