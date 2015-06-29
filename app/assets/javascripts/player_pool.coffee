window.divided?= {}
window.divided.playerPool = (options) ->
  {
    scaler,
    game,
    loadingText,
    directingPlayerUuid,
    extConfig,
    onDirectingPlayerDeath
  } = options

  lastRender = null

  obj = {
    renderer: window.divided.playerRenderer({
      scaler:                scaler,
      game:                  game,
      loadingText:           loadingText,
      directingPlayerUuid: directingPlayerUuid,
      extConfig:             extConfig
    })
    displayAllChoosing: () ->     obj.renderer.displayAllChoosing()
    markAsWaiting:      (uuid) -> obj.renderer.markAsWaiting(uuid)
    redraw: () ->
      if lastRender?
        obj.renderer.clearBodies()
        lastRender()
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

      lastRender = () ->
        at() for uuid, at of ats
        kill() for uuid, kill of kills

        for uuid, at of ats
          obj.renderer.markAsChoosing(uuid) if !kills[uuid]?
      lastRender()
  }
