class BoardController
  constructor: (@containerId, @assets) ->
  
  drawboard: ->
    squareSize = 10
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
    camera.position.set(squareSize * 4, 120, 150)
    cameraController = new THREE.OrbitControls(camera, @containerId)
    cameraController.center = new THREE.Vector3(squareSize * 4, 0, squareSize * 4)
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
    #materials.darkSquareMaterial = new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + 'square_dark_texture.jpg')})
    #materials.LightSquareMaterial = new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + 'square_light_texture.jpg')})
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
  DarkSquareMaterial: (direction) ->
    return new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + direction + '_arrow_dark_square_texture.png')})
  LightSquareMaterial: (direction) ->
    return new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + direction + '_arrow_light_square_texture.png')})
  InitObjects: (scene, cameraController, renderer, camera, materials)->
    squareSize = 10
    loader = new THREE.JSONLoader()
    totalObjectsToLoad = 2
    loadedObjects = 0
    board_geometry = (geom) ->
      console.log geom
      boardModel = new THREE.Mesh(geom, materials.boardMaterial)
      boardModel.position.y = -0.02
      scene.add(boardModel)
      checkLoad()
      return

    loader.load(@assets + 'board.js', board_geometry)
    piece_geometry = (geometry) ->
      console.log geometry
      pieceGeometry = geometry
      checkLoad()
      return

    loader.load(@assets + 'piece.js', piece_geometry)

    # Add ground
    groundModel = new THREE.Mesh(new THREE.PlaneGeometry(100, 100, 1, 1), materials.groundMaterial)
    groundModel.position.set(squareSize * 4, -1.52, squareSize * 4)
    groundModel.rotation.x = -90 * Math.PI / 180
    scene.add(groundModel)    
    scene.add(new THREE.AxisHelper(200))
    SquareMaterial
    directions = ['up','down','left','right']
    ###
    UP is 0
    DOWN is 1
    LEFT is 2
    RIGHT is 3
    ###
    direction_board = []
    for row in [0..7]
      direction_row = []
      for col in [0..7]
        random_direction = Math.floor(Math.random()*directions.length)
        direction_row.push random_direction
        if (row + col) % 2 == 0
          SquareMaterial = @LightSquareMaterial(directions[random_direction])
        else
          SquareMaterial = @DarkSquareMaterial(directions[random_direction])
        Square = new THREE.Mesh(new THREE.PlaneGeometry(squareSize, squareSize, 1, 1), SquareMaterial)
        Square.position.x = col * squareSize + squareSize / 2
        Square.position.z = row * squareSize + squareSize / 2
        Square.position.y = -0.01
        Square.rotation.x = -90 * Math.PI / 180
        scene.add(Square)
      console.log "random_direction is", direction_row
      direction_board.push direction_row
    console.log "direction board is", direction_board
    checkLoad = ->
      loadedObjects += 1
      if loadedObjects is totalObjectsToLoad      
        onAnimationFrame = ->
          requestAnimationFrame onAnimationFrame
          cameraController.update()
          renderer.render scene, camera  
          return
        onAnimationFrame()
        return
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