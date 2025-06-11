--resetbutton class--
local class = require "libraries/middleclass"
local SubmitButton = require "classes/SubmitButton"

DifficultyButton = class('DifficultyButton', SubmitButton)

function DifficultyButton:initialize(xPos, yPos, difficultyString, difficultyLevel )
  SubmitButton.initialize(self, xPos, yPos)
  self.graphic = love.graphics.newImage("assets/img/" .. difficultyString .. ".png")
  self.isSubmitButton = false
  self.isDifficultyButton = true
  self.difficultyLevel = difficultyLevel
  
end

return DifficultyButton