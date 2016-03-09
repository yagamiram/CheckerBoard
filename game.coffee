class BoardController
  constructor: (@containerId, @assets) ->
  drawboard: -> 
    @initEngine()  
  initEngine: ->
    viewWidth = @containerId.offsetWidth;
    viewHeight = @containerId.offsetHeight;
    renderer = new THREE.WebGLRenderer()
    renderer.setSize(viewWidth, viewHeight)
    scene = new THREE.Scene()
    camera = new THREE.PerspectiveCamera(
      50,
      viewWidth / viewHeight,
      0.1,
      2000)
    camera.position.set(150, 12, 150)
    cameraController = new THREE.OrbitControls(camera, @containerId)
    scene.add(camera)
    @containerId.appendChild(renderer.domElement)
    cube = new THREE.Mesh(new THREE.CubeGeometry(80, 50, 50))
    scene.add(cube)
    onAnimationFrame = ->
      requestAnimationFrame onAnimationFrame
      cameraController.update()
      renderer.render scene, camera	 
      return
    onAnimationFrame()
    return

class Game
  constructor: (@containerId, @assets) ->
    bc = new BoardController(@containerId, @assets)
    bc.drawboard()

class Checkers
  @containerId = document.getElementById('boardContainer')
  @assetsId = '3d_assets/'
  @game = new Game(@containerId, @assetsId)

c = new Checkers()