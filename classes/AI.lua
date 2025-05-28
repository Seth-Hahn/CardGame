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

function AI:takeTurn(turnNumber)
  local playLocations = {self.playLocationOne, self.playLocationTwo, self.playLocationThree}
  local amountOfMoves = turnNumber
  while amountOfMoves > 0 and #self.hand.cards > 0 do
    local locationToPlace = playLocations[love.math.random(1,3)] --determine random location to play card
    local cardToPlace = self.hand.cards[love.math.random(1,#self.hand.cards)] --pick random card to play
    
    cardToPlace:moveFromTo(cardToPlace.currentGroup, locationToPlace, self)
    
    amountOfMoves = amountOfMoves - 1
  end
end
return AI
