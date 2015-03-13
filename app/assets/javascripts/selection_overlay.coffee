window.divided?= {}
selectionOverlay = (options) ->
  xPosToX = options.xPosToX
  yPosToY = options.yPosToY
  obj = {
    setGame: (g) ->
      obj.game = g
      obj.glows = g.add.group()
      obj.popups = g.add.group()
    getGlow: (x,y) ->
      g = obj.glows.getFirstDead()
      if g
        g.reset(x,y)
      else
        g = obj.glows.create(x,y,'rgb_glow')
      g.anchor.set(0.5)
      g.alpha = 0
      g
    clearGlows: () ->
      obj.glows.callAllExists('fadeAndKill',true)
      obj.popups.destroy(true,true)
    getText: (content,xPos,yPos) ->
      x = xPosToX(xPos)
      y = yPosToY(yPos)
      console.log 'a'
      t = obj.game.add.text(
        x,
        y,
        content,
        {
          fill: "#ffffff", align: "center", stroke: '#000000', strokeThickness: 2
        }
      )
      console.log 'b'
      t.font = 'Arial'
      t.fontWeight = 'bold'
      t.fontSize = 15
      t.anchor.set(0.5)
      t.angle = 25
      console.log 'c'
      #text.alpha = 0.5;
      obj.popups.add(t)
      console.log 'd'
      t
  }
window.divided.selectionOverlay = selectionOverlay
