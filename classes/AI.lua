local Player = require "classes/Player"

--AI class-- 
local class = require 'libraries/middleclass'
local AI = class('AI', Player)

function AI:initialize(xPos, yPos, difficultyLevel)
  Player.initialize(self, xPos, yPos)
  
  self.isAI = true
  self.tag = "AI"
  self.difficulty = difficultyLevel
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
  love.graphics.print("Points:" .. self.points .. "/25", self.xPos + (self.xPos *.8) , self.yPos + (self.yPos * .8) )
  love.graphics.print("Difficulty:" .. self.difficulty, self.xPos + (self.xPos *.8) , self.yPos + (self.yPos / .2) )
  love.graphics.setFont(standardFont)
  
end

function AI:takeTurn(turnNumber)
  local playLocations = {self.playLocationOne, self.playLocationTwo, self.playLocationThree}
  local amountOfMoves = turnNumber - 1
  local playAnotherCard = true
  local chanceToStopPlayingCards = 0
  local manaCapMultiplier = 1
  
  if self.difficulty == 1 then --difficulty settings
    chanceToStopPlayingCards = 60
    manaCapMultiplier = 1.1
  elseif self.difficulty == 2 then
    chanceToStopPlayingCards = 50
    manaCapMultiplier = 1.5
    amountOfMoves = turnNumber
  elseif self.difficulty == 3 then
    chanceToStopPlayingCards = 25
    manaCapMultiplier = 2.5 
    amountOfMoves = turnNumber
  end
  
  local cardsInHandChecked = {}
  while amountOfMoves > 0 and #self.hand.cards > 0 and playAnotherCard do
    local locationToPlace = playLocations[love.math.random(1,3)] --determine random location to play card
    local cardToPlace = self.hand.cards[love.math.random(1,#self.hand.cards)] --pick random card to play
    for key, card in ipairs(cardsInHandChecked) do --put card in the checked cards table if not already in there 
      if card == cardToPlace then 
        break
      elseif card ~= cardToPlace and key == #cardsInHandChecked then
        table.insert(cardsInHandChecked, cardToPlace)
      end
    end
    local cardChosen = false
      if cardToPlace.cost < (manaCapMultiplier*turnNumber) then
        cardToPlace:moveFromTo(cardToPlace.currentGroup, locationToPlace, self)
        cardToPlace.isFaceUp = false
        table.insert(self.playedCards, cardToPlace)
        cardChosen = true
      end
      amountOfMoves = amountOfMoves - 1
      
    local coinFlip = love.math.random(0,100) --randomly determines if the ai will play another card
    if coinFlip <= chanceToStopPlayingCards then
      playAnotherCard = false
    elseif cardChosen == false and #cardsInHandChecked ~= #self.hand.cards then--pick another card if one wasnt played and they havent all been checked
      amountOfMoves = amountOfMoves + 1
    end
  end
end

return AI


