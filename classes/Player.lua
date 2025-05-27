local DrawDeck = require 'classes/DrawDeck'
local DiscardPile = require 'classes/DiscardPile'
local Hand = require 'classes/Hand'
local PlayLocation = require 'classes/PlayLocation'
local Card = require 'classes/Card'

--player class-- 
local class = require 'libraries/middleclass'
local Player = class('Player')

function Player:initialize(xPos, yPos)
  self.xPos = xPos
  self.yPos = yPos
  self.drawDeck = DrawDeck(xPos / 4, yPos + (yPos / 2))
  self.hand = Hand(xPos/ 1.6, yPos + (yPos / 2))
  self.discardPile = DiscardPile(xPos + (xPos * .6) , yPos + (yPos / 2))
  self.playLocationOne = PlayLocation(xPos / 2, yPos / 1.5, 'Location 1')
  self.playLocationTwo = PlayLocation(xPos / 1.25, yPos / 1.5, 'Location 2')
  self.playLocationThree = PlayLocation(xPos / .9, yPos / 1.5, 'Location 3')
  self.mana = 0
  self.points = 0
end


function Player:drawToScreen()
  --draw each card pile--
  self.drawDeck:drawToScreen()
  self.discardPile:drawToScreen()
  self.hand:drawToScreen()
  self.playLocationOne:drawToScreen()
  self.playLocationTwo:drawToScreen()
  self.playLocationThree:drawToScreen()
  
  --draw mana--
  local standardFont = love.graphics.getFont()
  local currentManafont = love.graphics.newFont(24)
  love.graphics.setFont(currentManafont)
  love.graphics.print("Current Mana:" .. self.mana, self.xPos, self.yPos + (self.yPos * .8) )
  love.graphics.print("Points:" .. self.points .. "/15", self.xPos + (self.xPos *.8) , self.yPos + (self.yPos * .8) )
  love.graphics.setFont(standardFont)
end

function Player:setupDeck()
  local cardNames = { 'minotaur', 'pegasus', 'titan',
                      'woodenCow', 'zeus', 'medusa', 
                      'artemis', 'swordOfDamocles', 'cyclops',
                      'helios'
                    }
  local cardCosts = {5, 3, 6,
                      1, 5, 4,
                      2, 3, 7,
                      2
                    }
  local cardPowers = {9, 5, 12,
                      1, 6, 2,
                      2, 7, 7,
                      9
                    }
      
  local cardEffects = {Card:noEffect(), Card:noEffect(), Card:noEffect(),
                        Card:noEffect(), Card:zeusEffect(), Card:medusaEffect(),
                        Card:artemisEffect(), Card:swordOfDamoclesEffect(), Card:cyclopsEffect(),
                        Card:heliosEffect()
                      }
  
  local cardTriggers = {nil, nil, nil, 
                        nil, 'onReveal', 'onSubmit',
                        'onReveal', 'onTurnEnd', 'onReveal',
                        'onTurnEnd'
                      }

                      
  --20 card deck with 2 copies of each card--
  for i = 1, 10, 1 do
    for j = 1, 2, 1 do
      local newCard = Card(cardNames[i], cardCosts[i], cardPowers[i], cardTriggers[i], cardEffects[i])
      newCard:setLocation(self.drawDeck.x, self.drawDeck.y - (self.drawDeck.y / 20))
      table.insert(self.drawDeck.cards, 1, newCard)
      newCard.group = self.drawDeck
    end
  end
  
  --shuffle the deck--
  self.drawDeck:shuffleDeck()
end
      

function Player:drawToHand(turnNumber)
  if turnNumber == 0 then --draw 3 cards on first turn
    for i = 1, 3, 1 do
      local cardToHand = table.remove(self.drawDeck.cards)
      table.insert(self.hand.cards, 1, cardToHand)
      cardToHand:setLocation(self.hand.x + (i*70), self.hand.y)
      cardToHand.isFaceUp = true
      cardToHand.currentGroup = self.hand
    end
  end
      
  
end
return Player
