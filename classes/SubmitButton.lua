--submit button class--
local class = require 'libraries/middleclass'

local SubmitButton = class('SubmitButton')

function SubmitButton:initialize(xPos, yPos) 
  self.graphic = love.graphics.newImage("assets/img/submitButton.png")
  self.x = xPos
  self.y = yPos
  self.width = self.graphic:getWidth()
  self.height = self.graphic:getHeight()
  self.isSubmitButton = true
end

function SubmitButton:drawToScreen()
  love.graphics.draw(self.graphic, self.x, self.y)
end

return SubmitButton