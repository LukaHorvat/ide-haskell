path = require 'path'
$ = require 'jquery'

getCabalProjectDir = ->
  # just want to check the project root directory, but getRootDirectory is deprecated.
  # getDirectories() returns a list of directories, including(only?) the project root, but it
  # isn't properly flagged as root (isRoot() returns false; it must be the filesystem root, not the project root).
  # So, just scan for cabal files in each directory.
  files = []
  for dir in atom.project.getDirectories()
    if dir # sometimes it is null...woooo
      files = files.concat dir.getEntriesSync()
  return null unless files?
  for file in files
    if path.extname(file.getPath()) is '.cabal'
      return path.dirname(file.getPath())

# check if project contains cabal file
isCabalProject = ->
  return getCabalProjectDir() != null

# check if file is haskell source code
isHaskellSource = (fname) ->
  if path.extname(fname) is '.hs'
    return true
  return false

getElementsByClass = (elem,klass) ->
  # this is pretty obtuse, but jquery doesn't seem to support inspecting the shadowRoot directly
  # can remove the fallback once the option to disable the shadow dom is gone
  if elem.shadowRoot
    if klass[0] == "."
      klass = klass.substring(1)
    elem.shadowRoot.getElementsByClassName(klass)
  else
    if klass[0] != "."
      klass = "." + klass
    $(elem).find(klass)

# pixel position from mouse event
pixelPositionFromMouseEvent = (editor, event) ->
  {clientX, clientY} = event
  elem = atom.views.getView(editor)
  linesClientRect = getElementsByClass(elem, ".lines")[0].getBoundingClientRect()
  top = clientY - linesClientRect.top
  left = clientX - linesClientRect.left
  {top, left}

# screen position from mouse event
screenPositionFromMouseEvent = (editor, event) ->
  editor.screenPositionForPixelPosition(pixelPositionFromMouseEvent(editor, event))

extendArray = (constructor) ->
  constructor.prototype.unique = ->
    output = {}
    output[@[key]] = @[key] for key in [0...@length]
    value for key, value of output


module.exports = {
  getElementsByClass,
  isCabalProject,
  isHaskellSource,
  pixelPositionFromMouseEvent,
  screenPositionFromMouseEvent,
  extendArray
}
