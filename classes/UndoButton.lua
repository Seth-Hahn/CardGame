--resetbutton class--
local class = require "libraries/middleclass"
local SubmitButton = require "classes/SubmitButton"

UndoButton= class('UndoButton', SubmitButton)

function UndoButton:initialize(xPos, yPos)
  SubmitButton.initialize(self, xPos, yPos)
  self.graphic = love.graphics.newImage("assets/img/undo.png")
  self.isSubmitButton = false
  self.isUndoButton = true
  
end

return UndoButton