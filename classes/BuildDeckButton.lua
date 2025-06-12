--resetbutton class--
local class = require "libraries/middleclass"
local SubmitButton = require "classes/SubmitButton"

BuildDeckButton = class('BuildDeckButton', SubmitButton)

function BuildDeckButton:initialize(xPos, yPos)
  SubmitButton.initialize(self, xPos, yPos)
  self.graphic = love.graphics.newImage("assets/img/buildDeckButton.png")
  self.isSubmitButton = false
  self.isBuildDeckButton = true
  
end

return BuildDeckButton