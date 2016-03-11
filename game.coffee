class BoardController
  constructor: (@containerId, @assets) ->
  drawboard: ->
    squareSize = 10
    pieceGeometry = null
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
    console.log "Retured from InitObjects"
    console.log "the piece geometry value is", pieceGeometry
    return

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
    pieceObjGroup = null
    keyboard = new THREEx.KeyboardState()
    is_tween_running = false
    current_location = []
    board_geometry = (geom) ->
      console.log geom
      boardModel = new THREE.Mesh(geom, materials.boardMaterial)
      boardModel.position.y = -0.02
      scene.add(boardModel)
      checkLoad()
      return
    console.log "Calling loader function to process board.js"
    loader.load(@assets + 'board.js', board_geometry)
    piece_geometry = (geometry) ->
      console.log "inside piece geometry", geometry
      @pieceGeometry = geometry
      checkLoad()
      return
    console.log "Calling loader fn to process piece.js"
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
    visited_board = []
    for row in [0..7]
      direction_row = []
      visited_row = []
      for col in [0..7]
        random_direction = Math.floor(Math.random()*directions.length)
        direction_row.push random_direction
        visited_row.push false
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
      #console.log "random_direction is", direction_row
      direction_board.push direction_row
      visited_board.push visited_row
    console.log "direction board is", direction_board
    move_object = (distance = 0.0) ->
      console.log "move object"
      pieceObjGroup.position.x += distance
      return # end of the move object function
    boardToWorld = (pos)->
      x = (1 + pos[1]) * squareSize - squareSize/2
      z = (1 + pos[0]) * squareSize - squareSize/2
      return new THREE.Vector3(x, 0, z)
    AddPiece = (piece) ->
      pieceMesh = new THREE.Mesh(@pieceGeometry)
      pieceObjGroup = new THREE.Object3D()
      pieceObjGroup.color = piece.color
      pieceObjGroup.material = materials.whitePieceMaterial
      shadowPlane = new THREE.Mesh(new THREE.PlaneGeometry(squareSize, squareSize, 1, 1), materials.pieceShadowPlane)
      shadowPlane.rotation.x = -90 * Math.PI / 180
      ###
      This commented because during this call the @pieceGeometry is not initialized and
      and it is set to NUll.
      PieceMesh is mesh of @PieceGeometry
      ###
      #pieceObjGroup.add(pieceMesh)  
      pieceObjGroup.add(shadowPlane)
      pieceObjGroup.position = boardToWorld(piece.pos)
      #board[piece.pos[0]][piece.pos[1]] = pieceObjGroup
      console.log "pieceObjGroup",pieceObjGroup
      scene.add(pieceObjGroup)
      return
    random_piece = { color : 0x9f2200, pos : []}
    # Get a random location
    random_piece.pos.push Math.floor(Math.random()*8)
    random_piece.pos.push Math.floor(Math.random()*8)
    console.log "random piece is", random_piece
    current_location = [random_piece.pos[0] , random_piece.pos[1]]
    AddPiece(random_piece)
    sleep = (ms) ->
      start = new Date().getTime()
      continue while new Date().getTime() - start < ms
    create_tween = (from, to_x, to_z)->
      # create the tween
      if ( is_tween_running is false )
        is_tween_running = true 
        #console.log "is_tween_running in create tween", is_tween_running
      values1 = 
        x: from.x
        y: 0
        z: from.z
        t: 0
      # the variable that changes, set to initial values
      target1 = 
        x: to_x
        y: 0
        z: to_z
        t: 0
      tween1 = new (TWEEN.Tween)(values1).to(target1, 3000)
      console.log "from is", values1
      console.log "to is", target1
      tween1.onUpdate ->
        pieceObjGroup.position.z = values1.z
        pieceObjGroup.position.y = values1.y
        pieceObjGroup.position.x = values1.x
        return
      tween1.onComplete ->
        console.log "changing the is_tween_running value", is_tween_running
        console.log pieceObjGroup.position.x, pieceObjGroup.position.z
        is_tween_running = false
      #tween1.delay 1000
      tween1.easing TWEEN.Easing.Linear.None
      # tween2.chain(tween1); // for cyclic behaviour. however, need to reset values object
      tween1.start()
      return # End of tween function
    update = ->
      
      #console.log "keyboard is", keyboard
      if ( 1 is 1)
        #console.log "key pressed", pieceObjGroup.position, is_tween_running
        visited = []
        #console.log "current_location", current_location, visited_board[current_location[0]][current_location[1]]
        while ( is_tween_running == false ) 
          if current_location[0] in [0,8] or current_location[1] in [0, 8] or visited_board[current_location[0]][current_location[1]] is true 
            console.log "cycle formed"
            return
          visited_board[current_location[0]][current_location[1]] = true
          if direction_board[current_location[0]][current_location[1]] is 0
            x = (1 + current_location[1]) * squareSize - squareSize/2
            z = (1 + current_location[0]-1) * squareSize - squareSize/2
            console.log "up"
            from = boardToWorld([current_location[0], current_location[1]])            
            console.log "from:", from.x , 0, from.z
            console.log "to:", x , 0, z
            create_tween(from, x, z)
            current_location = [current_location[0]-1, current_location[1]]
          else if direction_board[current_location[0]][current_location[1]] is 1
            x = (1 + current_location[1]) * squareSize - squareSize/2
            z = (1 + current_location[0]+1) * squareSize - squareSize/2
            console.log "down"
            from = boardToWorld([current_location[0], current_location[1]])            
            console.log "from:", from.x , 0, from.z
            console.log "to:", x , 0, z
            create_tween(from, x, z)
            current_location = [current_location[0]+1, current_location[1]]      
          else if direction_board[current_location[0]][current_location[1]] is 2   
            x = (1 + current_location[1]-1) * squareSize - squareSize/2
            z = (1 + current_location[0]) * squareSize - squareSize/2
            console.log "lrft"
            from = boardToWorld([current_location[0], current_location[1]])            
            console.log "from:", from.x , 0, from.z
            console.log "to:", x , 0, z
            create_tween(from, x, z)
            current_location = [current_location[0], current_location[1]-1]
          else
            x = (1 + current_location[1]+1) * squareSize - squareSize/2
            z = (1 + current_location[0]) * squareSize - squareSize/2
            console.log "right"
            from = boardToWorld([current_location[0], current_location[1]])            
            console.log "from:", from.x , 0, from.z
            console.log "to:", x , 0, z
            create_tween(from, x, z)
            current_location = [current_location[0], current_location[1]+1]              
          #visited_board[current_location[0]][current_location[1]] = true
      return # end of the update function
    checkLoad = ->
      console.log "checkLoad"
      loadedObjects += 1
      if loadedObjects is totalObjectsToLoad      
        onAnimationFrame = ->
          requestAnimationFrame onAnimationFrame
          cameraController.update()
          renderer.render scene, camera
          update()
          TWEEN.update();
          #is_tween_running = false
          
          return
        onAnimationFrame()
        #console.log "After animation frame", @pieceGeometry
        # Add a piece into the board in a random position
        #console.log "move the object"
    return 

class Game
  constructor: (@containerId, @assets) ->
    bc = new BoardController(@containerId, @assets)
    bc.drawboard()
    console.log "returned from drawboard"

class Checkers
  @containerId = document.getElementById('boardContainer')
  @assetsId = '3d_assets/'
  @game = new Game(@containerId, @assetsId)
  console.log "returned from Game"
  

c = new Checkers()