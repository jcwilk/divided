window.divided?= {}
window.divided.playerPool = (options) ->
  {
    xPosToX,
    yPosToY,
    game,
    loadingText,
    directingPlayerUuid,
    extConfig,
    onDirectingPlayerDeath
  } = options

  obj = {
    renderer: window.divided.playerRenderer({
      xPosToX:               xPosToX,
      yPosToY:               yPosToY,
      game:                  game,
      loadingText:           loadingText,
      directingPlayerUuid: directingPlayerUuid,
      extConfig:             extConfig
    })
    displayAllChoosing: () ->     obj.renderer.displayAllChoosing()
    markAsWaiting:      (uuid) -> obj.renderer.markAsWaiting(uuid)
    nextRound: (r) ->
      ats = {}
      kills = {}

      r(
        register: (uuid) ->
          at: (x,y) ->
            ats[uuid] = () ->
              if obj.renderer.isRenderingPlayer(uuid)
                obj.renderer.moveSprite(uuid,[x,y])
              else
                obj.renderer.newWaitingDoom(x,y,uuid)
            kill: () ->
              kills[uuid] = () ->
                obj.renderer.killSprite(uuid)
                if uuid == directingPlayerUuid
                  onDirectingPlayerDeath()
      )
      obj.renderer.markAllWaiting()

      at() for uuid, at of ats
      kill() for uuid, kill of kills

      for uuid, at of ats
        obj.renderer.markAsChoosing(uuid) if !kills[uuid]?
  }
