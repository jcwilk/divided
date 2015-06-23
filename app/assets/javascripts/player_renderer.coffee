window.divided?= {}
window.divided.playerRenderer = (options) ->
  {xPosToX,yPosToY,game} = options
  FACE_WIDTH = 30
  FACE_HEIGHT = 32

  {
    newWaitingDoom: (xPos,yPos,uuid) ->
      doom = game.add.sprite(
        xPosToX(xPos)-FACE_WIDTH/2, yPosToY(yPos)-FACE_HEIGHT/2, 'doomfaces'
      );

      doom.animations.add('waiting',[4,4,4,4,4,4,3,5],2,true);
      doom.animations.play('waiting');

      souls.add(doom);
      doom.currentPos = [xPos,yPos];
      doom.uuid = uuid;

      if(uuid === player_uuid) {
        doom.blip = game.add.sprite(14.5,-5,'player_blip',false);
        doom.blip.anchor.setTo(0.5);
        doom.addChild(doom.blip);
        loadingText.destroy();
      }

      return doom;
  }
  # mat = {}
  # all = []
  # at = (x,y) ->
  #   key = "#{x},#{y}"
  #   mat[key] ?= {}

  #   {
  #     addMoves: (newMoves) ->
  #       if Object.keys(newMoves).length > 0 && Object.keys(mat[key]).length == 0
  #         all.push at(x,y)
  #       $.extend(mat[key], newMoves)
  #     moves: mat[key]
  #     x: x
  #     y: y
  #   }

  # {
  #   all: all
  #   at: at
  # }
