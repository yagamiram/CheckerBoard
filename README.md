3D Checker Board Game 
Jibo Robotics Challenge
========

#### Challenge ####

The aim of the project is to create a lightweight 3D checker board game that shows a visualization of a coin moving on the checker board.
The game stops when the coin falls off from the board or it ends in a cycle.

Challenge Description:

Consider a checkerboard of unknown size. On each square is an arrow that randomly points either up, down, left, or right. A checker is placed on a random square. Each turn the checker moves one square in the direction of the arrow. Visualize an algorithm that determines if the checker moves off the edge of the board.

    Include UI controls to play, stop, and reset the game.
    Include UI controls to change the size of the board and to shuffle the arrows.
    Include audio to make things more interesting.
    Add some style to make it look good.

[Challenge Link](https://github.com/golgobot/programming-challenge)

### Project Development ###

The project is built in Electron with Coffeescript and JS libraries.
The main JS libraries that are used are:
Three.js
Tween.js
Dat-Gui.js

[Three.js](https://github.com/mrdoob/three.js) [Tween.js](https://github.com/CreateJS/TweenJS) [Dat.gui.js] (https://github.com/dataarts/dat.gui)
[Electron] (https://github.com/atom/electron)

### Project Description ###

A 3D checker-board is created and a coin is placed on the board in a random position. Each cell in the checker board
has any one of the up, down, left and right directions on it. The coin will move as per the direction on the cell in which 
it resides.

The coin stops when it falls off from the board or it ends in a loop/cycle.

Sample video of the link:
![Sample output GIF](https://zippy.gfycat.com/PlayfulGlumIndianelephant.gif)

### Installation and how to run the project###
Windows:
```
1. Intall node.js
In cmd prompt:
1. node -v
2. npm -v
3. npm init
4. npm i electron-prebuilt --save-dev
5. node_modules\.bin\electron project_dir
```
### Features in the Project ###
360 rotation of the 3D checker board.
Camera zoom's in and out with respect to mouse scrolling.
Can stop/pause the game at any point of time
Can restart/re-size the game at any point of time

### Requirements ###
WebGL

### Base Condition ###
The project runs in 8x8 checker board by default.
### NOTE ###
The project doesn't run if rows aren't same as columns.
