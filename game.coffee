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
    # Draw Board is the function which initalizes all the objects for the scene and 
    # animate the game.
    @InitCamera()
    @InitRenderer()
    @InitLights()
    @InitScene()
    @containerId.appendChild(@renderer.domElement)
    @gui()
    @InitMaterials()
    @InitObjects()
    @create_board()
    @AddPiece()
    return # End of draw board funtion

  InitScene: ->
    @scene = new THREE.Scene()
    @scene.add(@camera)
    @scene.add(@lights.topLight)    
    return # End of InitScene funtion

  InitRenderer: ->
    ###
    Setting up the three.js renderer.
    There are lots of renderers like SVG , canvas and WebGL renderer.
    But here WebGL renderer is used because it’s able to take advantage of the GPU, 
    which makes it several orders of magnitude more performant.
    Apparantely Three.js creates a canvas in the body of the HTML that will be used to render the scene.
    ###
    ###
    Standard code to check if WebGL is enabled in the browser or not.
    Detector is a JS object present in Detector.js file
    ###
    if ( ! Detector.webgl ) 
      Detector.addGetWebGLMessage()
    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize(@viewWidth, @viewHeight)
    return # End of renderer function

  InitCamera: ->
    ###
    The camera is eye of three.js
    To show what goes in the area of scene, camera is created.
    There are varieties of camera but the standard one - perspective camera is used
    The arguments passed are:
    field of view,
    aspect ratio,
    From how near to far the camer should render the scene. The objects that doesn't
    fall in the boundary of near and far will be omitted by the camera.
    ###
    field_of_view = 35
    aspect = @viewWidth / @viewHeight
    near = 1
    far = 1000
    @camera = new THREE.PerspectiveCamera(field_of_view, aspect, near, far)
    # To keep X-axis parallel to the screen the camera is positioned at 
    # @squaresize*4, 120, 150.
    # This is the perfect position for the camera for 8X8 Checkerboard
    # For the rest of the checker board the Z-axis has to be changed. 
    # Its good to zoom-out by scrolling the mouse down for large Checker boards.
    @camera.position.set(@squareSize * 4, 120, 150)
    # To control and track the mouse moments that will be passed to the camera object
    # to change its position and field of view, the OrbitControls are called.
    # This uses the JS library : Orbit Control.js
    @cameraController = new THREE.OrbitControls(@camera, @containerId)
    # Centering the Camera. Suitable only for 8X8 checkerboard.
    @cameraController.center = new THREE.Vector3(@squareSize * 4, 0, @squareSize * 4)
    return # End of camera funtion

  InitLights: ()->
    # To show the 3D objects using the camera, lights are needed
    # Basic light object called PointLight is used.
    # This added to the scene later in the code.
    @lights.topLight = new THREE.PointLight()
    @lights.topLight.position.set(0, 150, 0)
    @lights.topLight.intensity = 1.0

  InitMaterials: ->
    # Creating a boardMaterial instane
    # THREE.MeshLambertMaterial - A material for non-shiny (Lambertian) surfaces, evaluated per vertex.
    @materials.boardMaterial = new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + 'board_texture.jpg')})
    @materials.pieceShadowPlane = new THREE.MeshBasicMaterial({
      transparent : true, 
      map: THREE.ImageUtils.loadTexture(@assets + 'piece_shadow.png')})
    return # End of InitMaterials

  AddPiece: () ->
    ###
    This function adds the Checker coin onto the checker board
    A random position is calculated and added to the board.
    ###
    # To access the memeber variables of the BoardController inside the  nested functions
    # the "that" variable is used. How silly it is ?
    that = @    
    Create_piece = (piece) ->
      that.checker_coin = new THREE.Object3D()
      that.checker_coin.name = "Checker_Piece"
      ###
      The ground needs to be rotated -90 degree 
      along the X axis because a THREE.PlaneGeometry will be positioned along the XY plane.
      ###
      shadowPlane = new THREE.Mesh(new THREE.PlaneGeometry(that.squareSize, that.squareSize, 1, 1), that.materials.pieceShadowPlane)
      shadowPlane.rotation.x = -90 * Math.PI / 180 
      that.checker_coin.add(shadowPlane)
      # The position of the coin in checker board varies with the 2D and 3D
      # The 2D matrix [direction board] stores the location of Checker as row, col
      # but to make to visible in 3D the Board-to-World function is called.
      that.checker_coin.position = that.boardToWorld(piece.pos)
      that.scene.add(that.checker_coin)
      return # end of create piece function

    random_piece = { pos : [] }
    # Get a random location
    random_piece.pos.push Math.floor(Math.random()*@row+1)
    random_piece.pos.push Math.floor(Math.random()*@col+1)
    #console.log "random piece is", random_piece
    @current_location = [random_piece.pos[0] , random_piece.pos[1]]
    Create_piece(random_piece)
    return # End of Add piece function

  boardToWorld: (pos)->
    # Since the board is constructed with Cell whose size is 10
    # The position of each cell is calculated in simplest way.
    x = (1 + pos[1]) * @squareSize - @squareSize/2
    z = (1 + pos[0]) * @squareSize - @squareSize/2
    # The position is returned as 3D vector back.
    return new THREE.Vector3(x, 0, z)

  ###
  Since there are 4 light image and 4 dark images for 4 directions
  to randomly pick it the below function is called.
  ###
  DarkSquareMaterial: (direction) ->
    return new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + direction + '_arrow_dark_square_texture.png')})
  LightSquareMaterial: (direction) ->
    return new THREE.MeshLambertMaterial({map: THREE.ImageUtils.loadTexture(@assets + direction + '_arrow_light_square_texture.png')})
  
  ###
  The GUI for Start/Stop/Restart/Set Size.
  It used the DAT.GUI.JS library for simplicity.
  ###
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
        # Unless the size of the row and col mentioned is different from before
        # this function will not run.
        # It deletes the current cells from the checker board and increases the board size and ground size
        # to have better 3D look with new different cells with random directions.
        if c_row not in [0, that.row] and c_col not in [0, that.col]
          that.scene.remove(that.scene.getObjectByName("Checker_Board")) for each_col in [0..that.col] for each_row in [0..that.row]
          that.scene.remove(that.scene.getObjectByName("Checker_Piece"))
          board = that.scene.getObjectByName("3dBoard")
          # The Board of the Checker has to be scaled as per the new row and columns.
          # It is scaled 12% each time. 
          # This is calculated manually using the Chrome Dev Tools.
          board.scale.x = 1 + (0.12 * (c_row - 7))
          board.scale.z = 1 + (0.12 * (c_col - 7))
          that.row = c_row
          that.col = c_col
          # All the variables are cleared.
          that.has_start_button_clicked = false
          that.cycle_formed = false
          that.direction_board = []
          that.visited_board = []
          that.current_location = []     
          that.create_board()
          that.AddPiece()          
        return # End of Set size function
      Restart : ->
        # No big change between the set_size and restart function.
        that.has_start_button_clicked = false
        that.cycle_formed = false
        that.scene.remove(that.scene.getObjectByName("Checker_Board")) for each_col in [0..that.col] for each_row in [0..that.row]
        that.scene.remove(that.scene.getObjectByName("Checker_Piece"))
        that.direction_board = []
        that.visited_board = []
        that.current_location = []     
        that.create_board()
        that.AddPiece()
        return # End of restart function.
      x: 8 # Slider that starts from 8 to ends at 15
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
    ###
    Creating the 3D Checker board.
    The directions are mapped to a numerical value as
    UP - 0
    DOWN - 1
    LEFT - 2
    RIGHT - 3
    ###
    SquareMaterial
    directions = ['up','down','left','right']
    ###
    A For loop is constructed as per the rows and columns declared.
    Each time during the loop, a square cell is created
    and added to the scene.
    And the cell's direction is store in the direction_board 
    and it is marked as False in visited board.
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
        # Again Plane Geometry needs 90 degree rotation.
        Square.position.y = -0.01
        Square.rotation.x = -90 * Math.PI / 180
        @scene.add(Square)
      @direction_board.push direction_row
      @visited_board.push visited_row
    return # End of create board funtion

  InitObjects: ()->
    that = @
    loader = new THREE.JSONLoader()
    # To stop running game until the checker coin moves from one postion to another
    # position, this mutual exclusion, is_tween_running variable is used.
    # It stops the while loop to run further until the tween function
    # moved the coin from souce to destination point.
    # This is because, the update function where the while resides is called 60 times per second
    # by the renderer. So two thread using the common variable Checker_coin needs to avoid
    # race conditions.
    is_tween_running = false
    # The 3D board used in the game is loaded using JSON loader
    # The 3D board is constructed using dev tools like Maya, Dreaweaver and converted into JS file.
    board_geometry = (geom) ->
      #console.log geom
      boardModel = new THREE.Mesh(geom, that.materials.boardMaterial)
      boardModel.name = "3dBoard"
      boardModel.position.y = -0.02
      that.scene.add(boardModel)
      Animate()
      return

    loader.load(@assets + 'board.js', board_geometry)

    create_tween = (from, to)->
      ###
      THE most important function which helps to animate
      the coin's movement from source to destination.
      The library Tween.js helps a lot to make this 
      possible in most easiest way.
      The funtion will run only when it acquires the lock
      on the checkers coin by valuating the boolean variable is_tween_running.
      ###
      # create the tween
      if ( is_tween_running is false )
        is_tween_running = true 
      values1 = {x: from.x, y: 0, z: from.z, t: 0}
      target1 = {x: to.x, y: 0, z: to.z, t: 0}
      tween1 = new (TWEEN.Tween)(values1).to(target1, 3000)
      tween1.onUpdate ->
        that.checker_coin.position.z = values1.z
        that.checker_coin.position.y = values1.y
        that.checker_coin.position.x = values1.x
        return
      tween1.onComplete ->
        # The lock is released only when the tween is happened
        # successfuly. 
        is_tween_running = false
      # The coin's movement is linear!!
      tween1.easing TWEEN.Easing.Linear.None
      tween1.start()
      return # End of tween function

    update = ->
      ###
      This is function where the real algorithm resides.
      It checks if the coin falls off the board or ends in a cycle.
      If starts the game only when the start button is pressed and when 
      the it can locks the coin variable.
      It stops and doesn't process when cycle is formed or the coin moved out of the board.
      ###
      if that.has_start_button_clicked is true
        while ( that.cycle_formed is false and is_tween_running == false )
          if 0 > that.current_location[0] or that.current_location[0] > that.row or 0 > that.current_location[1] or that.current_location[1] > that.col 
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
            to = that.boardToWorld([that.current_location[0]-1, that.current_location[1]]) 
            that.current_location = [that.current_location[0]-1, that.current_location[1]]
          else if that.direction_board[that.current_location[0]][that.current_location[1]] is 1
            # Move Down
            to = that.boardToWorld([that.current_location[0]+1, that.current_location[1]])
            that.current_location = [that.current_location[0]+1, that.current_location[1]]      
          else if that.direction_board[that.current_location[0]][that.current_location[1]] is 2
            # Move Left   
            to = that.boardToWorld([that.current_location[0], that.current_location[1]-1])
            that.current_location = [that.current_location[0], that.current_location[1]-1]
          else
            # Move Right
            to = that.boardToWorld([that.current_location[0], that.current_location[1]+1])
            that.current_location = [that.current_location[0], that.current_location[1]+1]
          # Move the coin from "from" to "to" using tween.
          create_tween(from, to)              
      return # end of the update function

    Animate = ->
      # Animate is function which renders and updates the object's movement which 
      # is recorded by camera and showed in the screen.
      # Thanks to the contributors for Three.js, Tween.js, DAT.gui.js 
      # Its because of them this 3D game became more easier to code. :)
      requestAnimationFrame Animate
      that.cameraController.update()
      that.renderer.render that.scene, that.camera
      update()
      TWEEN.update();
      return # End of Animate Function
    return # End of Init Objects
###
Get the id of the area where the scene has to be built.
Create an instance to Board Controller and call the draw board function.
###
containerId = document.getElementById('boardContainer')
assetsId = '3d_assets/'
board = new BoardController(containerId, assetsId)
board.drawboard(containerId, assetsId)