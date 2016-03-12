###
Class Board Controller 
This class is the main core of the project.
for loose coupling. 

Board Controller does two main operations
1. Initialize
2. Animate

Initialize:
  It created the objetcts needed for a 3D game startinf from camera to checker board.
Animate:
  Whatever the objects added to the scene, it will rendered here.

This whole file is written in coffesscript which will be transpiled to javascript
during the compile time.

More comments are given inline to the code.
###
class BoardController
  constructor: (@containerId, @assets) ->
    ### 
    The constructor of the class gets the
    document Id of HTML where the 3D game has to projected.
    It gets the gallery folder called 3D assets from the variable @assets

    To access most of the 3D objets across the various modules, 
    the below variables are listed as member variable of this class.
    ###
    @camera # Takes care of the 3D camera features.
    @cameraController # It tracks the mouse controls and correlates with the camera movement.
    @viewWidth = @containerId.offsetWidth # This returns the width and height of the container in the HTML tag.
    @viewHeight = @containerId.offsetHeight
    @squareSize = 10 # Each cell in the checker board is assumed of size 10.
    @renderer # An object that converts 3D to 2D and renders it in the screen.
    @scene # It defines the area specified in the HTML where the checkboard will be placed.
    @lights = {} # To illuminate the scene
    @materials = {} # Several objects were used with different materials and they are stored in this object.
    # This boolean tracks if the start button to start the game. This var is set to False by re-start, set-size and stop button
    @has_start_button_clicked = false
    # Each board has a random direction and to keep an eye of all the directions, this array object is used.  
    @direction_board = [] 
    # To detec the cycle in best cost effective way, an array is set with False during the start of the game
    # The array will mark the cells that are already visited and helps to detect the cycle.
    @visited_board = []
    # The current postion of the coin in the checkerboard is stored here. It changes whenver the coin moves.
    @current_location = []
    # The checker coin it is.
    @checker_coin
    @row = 7 #The minimum number rows and columns of checker board is 8.
    @col = 7
    # To stop proceeding further in the game this boolean variable is declared.
    @cycle_formed = false
  drawboard: ->
    # Loose coupling everyting here
    @InitCamera()
    @InitRenderer()
    @InitLights()
    @InitScene()
    @containerId.appendChild(@renderer.domElement)
    @gui()
    @InitMaterials()
    @InitObjects()
    @Addground()
    @create_board()
    @AddPiece()
    return # End of draw board funtion
  InitScene: ->
    @scene = new THREE.Scene()
    @scene.add(@camera)
    @scene.add(@lights.topLight)    
    return # End of InitScene funtion
  InitRenderer: ->
    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize(@viewWidth, @viewHeight)
    return # End of renderer function
  InitCamera: ->
    @camera = new THREE.PerspectiveCamera(35, @viewWidth / @viewHeight, 1, 1000)
    @camera.position.set(@squareSize * 4, 120, 150)
    @cameraController = new THREE.OrbitControls(@camera, @containerId)
    @cameraController.center = new THREE.Vector3(@squareSize * 4, 0, @squareSize * 4)
    return # End of camera funtion
  InitLights: ()->
    # Need to more research on Lights - Three.js
    # If this function is disabled then the board is not visible in the app.
    @lights.topLight = new THREE.PointLight()
    @lights.topLight.position.set(0, 150, 0)
    #lights.topLight.add(new THREE.Mesh( new THREE.SphereGeometry( 1, 2, 8 ), new THREE.MeshBasicMaterial( { color: 0xffaa00 } ) ))
    @lights.topLight.intensity = 1.0
  InitMaterials: ->
    # Creating a boardMaterial instane
    # THREE.MeshLambertMaterial - A material for non-shiny (Lambertian) surfaces, evaluated per vertex.
    @materials.boardMaterial = new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + 'board_texture.jpg')})
    # Creating ground material
    # THREE.MeshBasicMaterial A material for drawing geometries in a simple shaded (flat or wireframe) way.
    @materials.groundMaterial = new THREE.MeshBasicMaterial({
      transparent : true, 
      map: THREE.ImageUtils.loadTexture(@assets + 'ground.png')})
    @materials.pieceShadowPlane = new THREE.MeshBasicMaterial({
      transparent : true, 
      map: THREE.ImageUtils.loadTexture(@assets + 'piece_shadow.png')})
    return # End of InitMaterials
  AddPiece: () ->
    that = @    
    Create_piece = (piece) ->
      that.checker_coin = new THREE.Object3D()
      that.checker_coin.name = "Checker_Piece"
      that.checker_coin.color = piece.color
      shadowPlane = new THREE.Mesh(new THREE.PlaneGeometry(that.squareSize, that.squareSize, 1, 1), that.materials.pieceShadowPlane)
      shadowPlane.rotation.x = -90 * Math.PI / 180 
      that.checker_coin.add(shadowPlane)
      that.checker_coin.position = that.boardToWorld(piece.pos)
      #console.log "checker_coin",that.checker_coin
      that.scene.add(that.checker_coin)
      return # end of create piece function
    random_piece = { color : 0x9f2200, pos : []}
    # Get a random location
    random_piece.pos.push Math.floor(Math.random()*@row+1)
    random_piece.pos.push Math.floor(Math.random()*@col+1)
    #console.log "random piece is", random_piece
    @current_location = [random_piece.pos[0] , random_piece.pos[1]]
    Create_piece(random_piece)
    return # End of Add piece function
  boardToWorld: (pos)->
    x = (1 + pos[1]) * @squareSize - @squareSize/2
    z = (1 + pos[0]) * @squareSize - @squareSize/2
    #console.log "Board to World : the x and z are", x, z
    return new THREE.Vector3(x, 0, z)
  DarkSquareMaterial: (direction) ->
    return new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + direction + '_arrow_dark_square_texture.png')})
  LightSquareMaterial: (direction) ->
    return new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + direction + '_arrow_light_square_texture.png')})
  gui: ->
    that = @
    c_row = 0
    c_col = 0
    gui = new (dat.GUI)
    parameters = 
      start :   ->
        that.has_start_button_clicked = true
        console.log "the has_start_button_clicked is changed to ", that.has_start_button_clicked
        return
      stop : ->
        that.has_start_button_clicked = false
        return
      set_size: ->
        console.log "either to update or remove the 3d model", c_row, c_col
        if c_row not in [0, that.row] and c_col not in [0, that.col]
          console.log "New board"
          that.scene.remove(that.scene.getObjectByName("Checker_Board")) for each_col in [0..that.col] for each_row in [0..that.row]
          that.scene.remove(that.scene.getObjectByName("Checker_Piece"))
          board = that.scene.getObjectByName("3dBoard")
          board.scale.x = 1 + (0.12 * (c_row - 7))
          board.scale.z = 1 + (0.12 * (c_col - 7))
          that.row = c_row
          that.col = c_col
          that.has_start_button_clicked = false
          that.cycle_formed = false
          that.direction_board = []
          that.visited_board = []
          that.current_location = []     
          that.create_board()
          that.AddPiece()          
        return # End of Set size function
      Restart : ->
        that.has_start_button_clicked = false
        that.cycle_formed = false
        that.scene.remove(that.scene.getObjectByName("Checker_Board")) for each_col in [0..that.col] for each_row in [0..that.row]
        that.scene.remove(that.scene.getObjectByName("Checker_Piece"))
        that.direction_board = []
        that.visited_board = []
        that.current_location = []     
        that.create_board()
        that.AddPiece()
        return
      x: 8
      y: 8
    # gui.add( parameters )
    gui.add(parameters, 'start').name 'Start'
    gui.add(parameters, 'stop').name 'Stop'
    gui.add(parameters, 'Restart').name 'Restart'
    slider = gui.addFolder('Checker Board Size')
    checker_row = slider.add(parameters, 'x').min(8).max(15).step(1).listen()
    checker_col = slider.add(parameters, 'y').min(8).max(15).step(1).listen()
    slider.add(parameters, 'set_size').name 'Set Size'
    slider.open() 
    checker_row.onChange (value) ->
      c_row = value-1
    checker_col.onChange (value) ->
      c_col = value-1
    slider.close()
    gui.open()
    return # End of GUI function 
  create_board: () ->
    #console.log "Create a new board"
    SquareMaterial
    directions = ['up','down','left','right']
    ###
    UP is 0
    DOWN is 1
    LEFT is 2
    RIGHT is 3
    ###
    for c_row in [0..@row]
      direction_row = []
      visited_row = []
      for c_col in [0..@col]
        random_direction = Math.floor(Math.random()*directions.length)
        direction_row.push random_direction
        visited_row.push false
        if (c_row + c_col) % 2 == 0
          SquareMaterial = @LightSquareMaterial(directions[random_direction])
        else
          SquareMaterial = @DarkSquareMaterial(directions[random_direction])
        Square = new THREE.Mesh(new THREE.PlaneGeometry(@squareSize, @squareSize, 1, 1), SquareMaterial)
        Square.name = "Checker_Board"
        Square.position.x = c_col * @squareSize + @squareSize / 2
        Square.position.z = c_row * @squareSize + @squareSize / 2
        Square.position.y = -0.01
        Square.rotation.x = -90 * Math.PI / 180
        @scene.add(Square)
      @direction_board.push direction_row
      @visited_board.push visited_row
    return # End of create board funtion
  Addground: () ->
    groundModel = new THREE.Mesh(new THREE.PlaneGeometry(@row*10+30, @col*10+30, 1, 1), @materials.groundMaterial)
    groundModel.name = "groundModel"
    groundModel.position.set(@squareSize * (@row+1)/2, -1.52, @squareSize * (@col+1)/2)
    groundModel.rotation.x = -90 * Math.PI / 180
    @scene.add(groundModel) 
    return # End of add ground
  InitObjects: ()->
    that = @
    loader = new THREE.JSONLoader()
    totalObjectsToLoad = 2
    loadedObjects = 0
    checker_coin = null
    is_tween_running = false
    current_location = []
    board_geometry = (geom) ->
      #console.log geom
      boardModel = new THREE.Mesh(geom, that.materials.boardMaterial)
      boardModel.name = "3dBoard"
      boardModel.position.y = -0.02
      that.scene.add(boardModel)
      Animate()
      return
    #console.log "Calling loader function to process board.js"
    loader.load(@assets + 'board.js', board_geometry)
    # Add ground   
    #@scene.add(new THREE.AxisHelper(200))
    #console.log "direction board is", @direction_board
    create_tween = (from, to)->
      # create the tween
      if ( is_tween_running is false )
        is_tween_running = true 
        #console.log "running from", from.x, from.y , "to :", to.x, to.y
      values1 = {x: from.x, y: 0, z: from.z, t: 0}
      target1 = {x: to.x, y: 0, z: to.z, t: 0}
      tween1 = new (TWEEN.Tween)(values1).to(target1, 3000)
      tween1.onUpdate ->
        that.checker_coin.position.z = values1.z
        that.checker_coin.position.y = values1.y
        that.checker_coin.position.x = values1.x
        return
      tween1.onComplete ->
        #console.log "tween1.onComplete is false"
        is_tween_running = false
      tween1.easing TWEEN.Easing.Linear.None
      tween1.start()
      return # End of tween function
    update = ->
      if that.has_start_button_clicked is true
        while ( that.cycle_formed is false and is_tween_running == false )
          ##console.log "the current_location is", that.current_location[0], that.current_location[1] 
          if 0 > that.current_location[0] or that.current_location[0] > that.row or 0 > that.current_location[1] or that.current_location[1] > that.col 
            ##console.log "Cycle formed", that.current_location[0], that.current_location[1]
            alert "Oops! The coin fallen from the Londen Bridge aka from the Checker Board! Press Restart for a new game"
            that.cycle_formed = true
            return
          else if that.visited_board[that.current_location[0]][that.current_location[1]] is true
            alert "Oops ! The coin is trapped in a cycle! Press Restart for a new game"
            that.cycle_formed = true
            return
          that.visited_board[that.current_location[0]][that.current_location[1]] = true
          from = that.boardToWorld([that.current_location[0], that.current_location[1]]) 
          if that.direction_board[that.current_location[0]][that.current_location[1]] is 0
            # Move UP
            ##console.log "Up"
            ##console.log "From is", from.x, from.y
            to = that.boardToWorld([that.current_location[0]-1, that.current_location[1]]) 
            #console.log "to is", to.x, to.y           
            that.current_location = [that.current_location[0]-1, that.current_location[1]]
          else if that.direction_board[that.current_location[0]][that.current_location[1]] is 1
            # Move Down
            #console.log "Down"
            #console.log "From is", from.x, from.y
            to = that.boardToWorld([that.current_location[0]+1, that.current_location[1]])
            #console.log "to is", to.x, to.y
            that.current_location = [that.current_location[0]+1, that.current_location[1]]      
          else if that.direction_board[that.current_location[0]][that.current_location[1]] is 2
            # Move Left   
            #console.log "Left"
            #console.log "From is", from.x, from.y
            to = that.boardToWorld([that.current_location[0], that.current_location[1]-1])
            #console.log "to is", to.x, to.y             
            that.current_location = [that.current_location[0], that.current_location[1]-1]
          else
            # Move Right
            #console.log "Right"
            #console.log "From is", from.x, from.y
            to = that.boardToWorld([that.current_location[0], that.current_location[1]+1])
            #console.log "to is", to.x, to.y          
            that.current_location = [that.current_location[0], that.current_location[1]+1]
          create_tween(from, to)              
      return # end of the update function
    Animate = ->
      requestAnimationFrame Animate
      that.cameraController.update()
      that.renderer.render that.scene, that.camera
      update()
      TWEEN.update();
      return # End of Animate Function
    return # End of Init Objects
containerId = document.getElementById('boardContainer')
assetsId = '3d_assets/'
board = new BoardController(containerId, assetsId)
board.drawboard(containerId, assetsId)