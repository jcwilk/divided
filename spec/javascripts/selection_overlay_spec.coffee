//= require selection_overlay

describe "Selection Overlay", () ->
  options = {
    scaler: {}
    extConfig: {blinkDelay: 100}
    remoteScaler: {}
    game: {
      add: {
        group: -> "new_group"
      }
      input: {
        onUp: {
          add: ->
        }
      }
    }
  }
  so = null

  beforeEach ->
    so = window.divided.selectionOverlay(options)

  it "returns an object", ->
    expect(so).toEqual(jasmine.any(Object))
