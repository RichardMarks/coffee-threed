{min, max, PI} = Math
PI_2 = PI * 0.5

module.exports = Controls: class Controls
  @MOVE_SPEED: 400.0
  @MASS: 100.0
  @GRAVITY: 9.8
  @JUMP_SPEED: 350
  @X_ROT: 0.002
  @Y_ROT: 0.002
  @Y_POS: 10
  constructor: (camera) ->
    move =
      forward: false
      backward: false
      left: false
      right: false
    state =
      isOnObject: false
      canJump: false
    lastTime = performance.now()
    velocity = new THREE.Vector3
    yaw = new THREE.Object3D
    pitch = new THREE.Object3D
    camera.rotation.set 0, 0, 0
    pitch.add camera
    yaw.position.y = Controls.Y_POS
    yaw.add pitch
    enabled = false
    @enable = -> enabled = true
    @disable = -> enabled = false
    @getObject = -> yaw
    @isOnObject = (flag) ->
      state.isOnObject = flag
      state.canJump = flag
    @getDirection = ->
      direction = new THREE.Vector3 0, 0, -1
      rotation = new THREE.Euler 0, 0, 0, 'YXZ'
      (v) ->
        rotation.set pitch.rotation.x, yaw.rotation.y, 0
        v.copy direction
        .applyEuler rotation
        v
    @update = ->
      return if not enabled
      time = performance.now()
      delta = (time - lastTime) * 0.001
      velocity.x -= velocity.x * 10.0 * delta
      velocity.z -= velocity.z * 10.0 * delta
      velocity.y -= Controls.GRAVITY * Controls.MASS * delta
      velocity.z -= Controls.MOVE_SPEED * delta if move.forward
      velocity.z += Controls.MOVE_SPEED * delta if move.backward
      velocity.x -= Controls.MOVE_SPEED * delta if move.left
      velocity.x += Controls.MOVE_SPEED * delta if move.right
      velocity.y = max 0, velocity.y if state.isOnObject
      yaw.translateX velocity.x * delta
      yaw.translateY velocity.y * delta
      yaw.translateZ velocity.z * delta
      if yaw.position.y < Controls.Y_POS
        velocity.y = 0
        yaw.position.y = Controls.Y_POS
        state.canJump = true
      lastTime = time
    onMouseMove = (mouseEvent) ->
      return if not enabled
      x = mouseEvent.movementX or 0
      y = mouseEvent.movementY or 0
      yaw.rotation.y -= x * Controls.X_ROT
      pitch.rotation.x -= y * Controls.Y_ROT
      pitch.rotation.x = max -PI_2, min PI_2, pitch.rotation.x
    onKeyDown = (keyEvent) ->
      jump = ->
        velocity.y += Controls.JUMP_POWER if state.canJump
        state.canJump = false
      switch keyEvent.keyCode
        when 38, 87 then move.forward = true
        when 37, 65 then move.left = true
        when 40, 83 then move.backward = true
        when 39, 68 then move.right = true
        when 32 then jump()
    onKeyUp = (keyEvent) ->
      switch keyEvent.keyCode
        when 38, 87 then move.forward = false
        when 37, 65 then move.left = false
        when 40, 83 then move.backward = false
        when 39, 68 then move.right = false
    document.addEventListener 'mousemove', onMouseMove, false
    document.addEventListener 'keydown', onKeyDown, false
    document.addEventListener 'keyup', onKeyUp, false
