class BoardController
  constructor: (@containerId, @assets) ->
  drawboard: ->
    viewWidth = @containerId.offsetWidth;
    viewHeight = @containerId.offsetHeight;
    renderer = new THREE.WebGLRenderer()
    renderer.setSize(viewWidth, viewHeight)
    scene = new THREE.Scene()
    camera = new THREE.PerspectiveCamera(
      35,
      viewWidth / viewHeight,
      1,
      1000)
    camera.position.set(0, 120, 150)
    cameraController = new THREE.OrbitControls(camera, @containerId)
    scene.add(camera)
    @containerId.appendChild(renderer.domElement)
    @InitLights(scene)
    materials = @InitMaterials()
    @InitObjects(scene, cameraController, renderer, camera, materials)
  InitLights: (scene)->
    lights = {}
    lights.topLight = new THREE.PointLight()
    lights.topLight.position.set(0, 150, 0)
    #lights.topLight.add(new THREE.Mesh( new THREE.SphereGeometry( 1, 2, 8 ), new THREE.MeshBasicMaterial( { color: 0xffaa00 } ) ))
    lights.topLight.intensity = 1.0
    scene.add(lights.topLight)
  InitMaterials: ->
    # Creating JS object.
    materials = {}
    # Creating a boardMaterial instane
    # THREE.MeshLambertMaterial - A material for non-shiny (Lambertian) surfaces, evaluated per vertex.
    materials.boardMaterial = new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + 'board_texture.jpg')})
    # Creating ground material
    # THREE.MeshBasicMaterial A material for drawing geometries in a simple shaded (flat or wireframe) way.
    materials.groundMaterial = new THREE.MeshBasicMaterial({
      transparent : true, 
      map: THREE.ImageUtils.loadTexture(@assets + 'ground.png')})
    materials.darkSquareMaterial = new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + 'square_dark_texture.jpg')})
    materials.LightSquareMaterial = new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + 'square_light_texture.jpg')})
    materials.whitePieceMaterial = new THREE.MeshPhongMaterial({
      color : 0xe9e4bd,
      shininess : 20
      })
    materials.blackPieceMaterial = new THREE.MeshPhongMaterial({
      color : 0x9f2200,
      shininess : 20
      })
    materials.pieceShadowPlane = new THREE.MeshBasicMaterial({
      transparent : true, 
      map: THREE.ImageUtils.loadTexture(@assets + 'piece_shadow.png')})
    return materials    

  InitObjects: (scene, cameraController, renderer, camera, materials)->
    loader = new THREE.JSONLoader()
    totalObjectsToLoad = 2
    loadedObjects = 0
    board_geometry = (geom) ->
      boardModel = new THREE.Mesh(geom, materials.boardMaterial)
      scene.add(boardModel)

    loader.load(@assets + 'board.js', board_geometry)
    piece_geometry = (geometry) ->
      pieceGeometry = geometry
    loader.load(@assets + 'piece.js', piece_geometry)
    scene.add(new THREE.AxisHelper(200))
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