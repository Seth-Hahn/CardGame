local Player = require "classes/Player"

--AI class-- 
local class = require 'libraries/middleclass'
local AI = class('AI', Player)

function AI:initialize(xPos, yPos)
  Player.initialize(self, xPos, yPos)
  
  self.isAI = true
end

function AI:drawToScreen()
  self.drawDeck:drawToScreen()
  self.discardPile:drawToScreen()
  self.playLocationOne:drawToScreen()
  self.playLocationTwo:drawToScreen()
  self.playLocationThree:drawToScreen()
  
  local standardFont = love.graphics.getFont()
  local aiHandSizeFont = love.graphics.newFont(24)
  love.graphics.setFont(aiHandSizeFont)
  love.graphics.print("Number of cards in AI hand:" .. #self.hand.cards, self.xPos, self.yPos)
  love.graphics.setFont(standardFont)
end
return AI
