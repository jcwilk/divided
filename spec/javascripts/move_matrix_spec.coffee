//= require move_matrix

describe "Move Matrix", () ->
  mm = null

  beforeEach () ->
    mm = window.MoveMatrix()

  describe "at", () ->
    describe "when there are other `at` scope instances"
      at1 = null
      at2 = null

      beforeEach () ->
        at1 = mm.at(1,1)
        at2 = mm.at(1,1)

      it "correctly reflects changes made by other `at` scopes", () ->
        at1.addMoves(tricky: 'business')
        expect(at2.moves.tricky).toEqual('business')

  describe "addMoves", () ->
    [x,y] = [0,0]
    link = "linky"
    action = "axn"

    addMoves = () ->
      newMoves = {}
      newMoves[action] = link
      mm.at(x,y).addMoves(newMoves)

    moveCount = () ->
      (k for own k of mm.at(x,y).moves).length

    it "adds a possible move at the specified location", () ->
      old_count = moveCount()
      addMoves()
      expect(moveCount()).toEqual(old_count+1)

    it "reflects the action", () ->
      addMoves()
      expect(mm.at(x,y).moves[action]).toBeDefined()
