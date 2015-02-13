//= require move_matrix

describe "Move Matrix", () ->
  mm = null

  beforeEach () ->
    mm = window.MoveMatrix()

  describe "addMove", () ->
    [x,y] = [0,0]

    addMove = () ->
      mm.at(x,y).addMove("linky")

    it "adds a possible move at the specified location", () ->
      expect(mm.at(x,y).moves.attack).toEqual(null)
      addMove()
      expect(mm.at(x,y).moves.attack).toEqual("linky")
