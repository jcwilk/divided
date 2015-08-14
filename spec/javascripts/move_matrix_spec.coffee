//= require move_matrix

describe "Move Matrix", () ->
  mm = null

  beforeEach () ->
    mm = window.divided.moveMatrix()

  describe "at", () ->
    describe "when there are other `at` scope instances", () ->
      at1 = null
      at2 = null

      beforeEach () ->
        at1 = mm.at(1,2)
        at2 = mm.at(1,2)

      it "correctly reflects changes made by other `at` scopes", () ->
        at1.addMoves(tricky: 'business')
        expect(at2.moves.tricky).toEqual('business')

      it "identifies as the correct x,y", () ->
        expect(at1.x).toEqual(1)
        expect(at1.y).toEqual(2)

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

  describe "all", () ->
    describe "without any moves added", () ->
      it "is empty", () ->

    describe "after two moves have been added to the same spot", () ->
      beforeEach () ->
        mm.at(3,4).addMoves(att: 'yep')
        mm.at(3,4).addMoves(woop: 'holla')

      it "contains one spot", () ->
        expect(mm.all.length).toEqual(1)

      it "has two moves at the spot", () ->
        expect(Object.keys(mm.all[0].moves).length).toEqual(2)

      it "represents the correct position", () ->
        expect(mm.all[0].x).toEqual(3)
        expect(mm.all[0].y).toEqual(4)

  describe "any", ->
    beforeEach ->
      mm.at(3,4).addMoves(att: 'ya')

    it 'is false at an empty spot', ->
      expect(mm.at(4,3).any()).toBeFalsy()

    it 'is true at a spot with moves', ->
      expect(mm.at(3,4).any()).toBeTruthy()

