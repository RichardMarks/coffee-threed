{Controls} = require './Controls'

THREE.Scene::clear = ->
  {children} = @
  children.pop() while children.length > 0 if children
  @

module.exports = App: class App
  init: (parentElement, onComplete) ->
    @nearZ = 0.1
    @farZ = 100.0
    @origin = x: 0, y: 0, z: 300
    @fov = 60
    @width = window.innerWidth
    @height = window.innerHeight
    @aspect = @width / @height
    @hasFocus = true
    @renderer = new THREE.WebGLRenderer
    @renderer.setSize @width, @height
    parentElement.appendChild @renderer.domElement
    @camera = new THREE.PerspectiveCamera @fov, @aspect, @nearZ, @farZ
    @camera.position.set @origin.x, @origin.y, @origin.z
    @scene = new THREE.Scene
    @clock = new THREE.Clock
    @controls = new Controls @camera
    window.onblur = @onLostFocus
    window.onfocus = @onGainFocus
    window.addEventListener 'resize', (=> @onResize()), false
    onComplete? @
  setupPointerLock: (blockerElement, instructionsElement) ->
    pointerLockAvailable = 'pointerLockElement' of document
    if not pointerLockAvailable
      instructionsElement.innerHTML = 'Your browser does not seem to support the pointer lock api :('
    else
      {body} = document
      onChange = =>
        if body is document.pointerLockElement
          @controls.enabled = true
          blockerElement.style.display = 'none'
        else
          @controls.enabled = false
          blockerElement.style.display = 'box'
          instructionsElement.style.display = 'none'
      onError = -> instructionsElement.style.display = 'none'
      onToggle = ->
        instructionsElement.style.display = 'none'
        body.requestPointerLock()
      document.addEventListener 'pointerlockchange', onChange, false
      document.addEventListener 'pointerlockerror', onError, false
      instructionsElement.addEventListener 'click', onToggle, false
  create: (onComplete) ->
    {scene, controls} = @
    o = @objects =
      lights: {}
      geometries: {}
      materials: {}
      meshes: {}
    createLights = ->
      o.lights =
        ambient:
          white: new THREE.AmbientLight 0x101010
        directional:
          sun: new THREE.DirectionalLight 0xffffff, 1
    createGeometries = ->
      o.geometries =
        cube: new THREE.BoxGeometry 10, 10, 10
    createMaterials = ->
      phongRedDef =
        ambient: 0x030303
        color: 0xff0000
        specular: 0x905000
        shininess: 30
        shading: THREE.FlatShading
      o.materials =
        basic:
          green: new THREE.MeshBasicMaterial color: 0x00ff00
        lambert:
          red: new THREE.MeshLambertMaterial color: 0xff0000
        phong:
          red: new THREE.MeshPhongMaterial phongRedDef
    createMeshes = ->
      o.meshes = {}
      geometry = o.geometries.cube
      material = o.materials.lambert.red
      o.meshes.cube = new THREE.Mesh geometry, material
      {random} = Math
      randomCube = ->
        material = o.materials.basic.green
        mesh = new THREE.Mesh geometry, material
        mesh.position.x = 20 * (10 + random() * 10) | 0
        mesh.position.y = 20 * (10 + random() * 10) | 0
        mesh.position.z = 20 * (10 + random() * 10) | 0
        mesh
      o.meshes.world = (randomCube() for i in [0...500])
    buildScene = ->
      scene.clear()
      scene.add controls.getObject()
      o.lights.directional.sun.position.set 0.5, 0.5, 2.0
      scene.add o.lights.directional.sun
      scene.add o.lights.ambient.white
      scene.add o.meshes.cube
      scene.add mesh for mesh in o.meshes.world
    createLights()
    createGeometries()
    createMaterials()
    createMeshes()
    buildScene()
    onComplete? @
  update: -> @controls.update()
  render: ->
    {renderer, scene, camera} = @
    renderer.render scene, camera
  onLostFocus: => @hasFocus = false
  onGainFocus: => @hasFocus = true
  onResize: ->
    w = window.innerWidth
    h = window.innerHeight
    aspect = w / h
    @aspect = aspect
    @width = w
    @height = h
    {camera, renderer} = @
    renderer.setSize width, height
    camera.aspect = aspect
    camera.updateProjectionMatrix()