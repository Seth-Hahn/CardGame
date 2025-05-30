--resetbutton class--
local class = require "libraries/middleclass"
local SubmitButton = require "classes/SubmitButton"

ResetButton = class('ResetButton', SubmitButton)

function ResetButton:initialize(xPos, yPos)
  SubmitButton.initialize(self, xPos, yPos)
  self.graphic = love.graphics.newImage("assets/img/resetButton.png")
  self.isSubmitButton = false
  self.isResetButton = true
end

return ResetButton