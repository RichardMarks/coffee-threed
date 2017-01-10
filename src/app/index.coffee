{App} = require './App'
fail = (why) -> throw new Error why
boot = ->
  # fail 'Error: THREE js Not Loaded!' if window.THREE?
  parent = document.getElementById 'game'
  blocker = document.getElementById 'blocker'
  instructions = document.getElementById 'instructions'
  app = new App
  app.init parent, ->
    app.setupPointerLock blocker, instructions
    app.create ->
      mainLoop = ->
        window.requestAnimationFrame mainLoop
        app.update() if app.hasFocus
        app.render()
      mainLoop()
document.addEventListener 'DOMContentLoaded', boot, false

