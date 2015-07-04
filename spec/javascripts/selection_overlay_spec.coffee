//= require selection_overlay

describe "Selection Overlay", () ->
  options = {
    scaler: {}
    extConfig: {blinkDelay: 100}
    game: {
      add: {
        group: () -> "new_group"
      }
    }
  }
  so = null

  beforeEach () ->
    so = window.divided.selectionOverlay(options)

  it "returns an object", () ->
    expect(so).toEqual(jasmine.any(Object))
