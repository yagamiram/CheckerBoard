'use strict'
electron = require('electron')
app = require('app')
# Module to control application life.
BrowserWindow = electron.BrowserWindow
# Module to create native browser window.
# Keep a global reference of the window object, if you don't, the window will
# be closed automatically when the JavaScript object is garbage collected.
mainWindow = null
# This method will be called when Electron has finished
# initialization and is ready to create browser windows.
app.on 'ready', ->
  # Create the browser window.
  mainWindow = new BrowserWindow(
    width: 800
    height: 600)
  #document.write("hi");
  # and load the index.html of the app.
  mainWindow.loadURL 'file://' + __dirname + '/index.html'
  #mainWindow.webContents.openDevTools();
  return