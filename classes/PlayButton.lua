--resetbutton class--
local class = require "libraries/middleclass"
local SubmitButton = require "classes/SubmitButton"

PlayButton = class('PlayButton', SubmitButton)

function PlayButton:initialize(xPos, yPos)
  SubmitButton.initialize(self, xPos, yPos)
  self.graphic = love.graphics.newImage("assets/img/playButton.png")
  self.isSubmitButton = false
  self.isPlayButton = true
  
end

return PlayButton