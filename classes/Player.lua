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
  self.playLocationOne = PlayLocation(xPos / 2, yPos / 1.5, 'Location 1', self)
  self.playLocationTwo = PlayLocation(xPos / 1.25, yPos / 1.5, 'Location 2', self)
  self.playLocationThree = PlayLocation(xPos / .9, yPos / 1.5, 'Location 3', self)
  self.mana = 1
  self.points = 0
  self.playedCards = {}
  
  self.flipIndex = 1
  self.flipTimer = 0
  self.tag = "Player"
  self.opposingPlayer = nil
  self.referenceToGameObjectList = {}
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
  love.graphics.print("Points:" .. self.points .. "/25", self.xPos + (self.xPos *.8) , self.yPos + (self.yPos * .8) )
  love.graphics.setFont(standardFont)
end

function Player:setupDeck()
  local cardNames = { 'minotaur', 'pegasus', 'titan',
                      'woodenCow', 'zeus', 'medusa', 
                      'artemis', 'swordOfDamocles', 'cyclops',
                      'helios', 'nyx', 'icarus',
                      'hydra', 'hercules', 'ares',
                      'shipOfTheseus', 'pandora' , 'hades',
                      'atlas',
                    }
  local cardCosts = {5, 5, 6,  --minotaur, pegasus, titan
                      1, 5, 1, --woodenCow, zues, medusa
                      2, 3, 4, --artemis, swordofdamocles, cyclops
                      2, 3, 1,  --helios, nyx, icarus
                      1, 2, 3,    --hydra, hercules, ares
                      1, 5, 4,      --theseus, pandora, hades
                      3,          --atlas
                    }
  local cardPowers = {9, 9, 12,
                      1, 9, 2,
                      2, 7, 7,
                      9, 5, 1,
                      3, 4, 5,
                      1, 10, 6,
                      6,
                    }
      
  local cardEffects = {Card.noEffect, Card.noEffect, Card.noEffect,
                        Card.noEffect, Card.zeusEffect, Card.medusaEffect,
                        Card.artemisEffect, Card.swordOfDamoclesEffect, Card.cyclopsEffect,
                        Card.heliosEffect, Card.nyxEffect, Card.icarusEffect,
                        Card.hydraEffect, Card.herculesEffect, Card.aresEffect,
                        Card.shipOfTheseusEffect, Card.pandoraEffect, Card.hadesEffect,
                        Card.atlasEffect,
                      }
  
  local cardTriggers = {'vanilla' , 'vanilla' , 'vanilla', 
                        'vanilla' , 'onReveal', 'whileActive',
                        'onReveal', 'onTurnEnd', 'onReveal',
                        'onTurnEnd', 'onReveal', 'onTurnEnd',
                        'onDiscard', 'onReveal', 'onReveal',
                        'onReveal', 'onReveal', 'onReveal',
                        'onTurnEnd',
                      }

                      
  --20 card deck with 2 copies of each card--
  for i = 1, #cardNames, 1 do
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
  if turnNumber == 1 then --draw 3 cards on first turn
    for i = 1, 3, 1 do
      local cardToHand = table.remove(self.drawDeck.cards)
      table.insert(self.hand.cards, 1, cardToHand)
      cardToHand:setLocation(self.hand.x + (i*70), self.hand.y)
      cardToHand.isFaceUp = true
      cardToHand.currentGroup = self.hand
    end
  else 
    if #self.hand.cards < 7 then -- cannot draw a card if hand is full
      local cardToHand = table.remove(self.drawDeck.cards)
      table.insert(self.hand.cards, cardToHand)
      if #self.hand.cards == 1 then
        newXCoord = self.hand.x
      else
        newXCoord = self.hand.x + #self.hand.cards * 70 
      end
      cardToHand:setLocation(newXCoord, self.hand.y)
      cardToHand.isFaceUp = true
      cardToHand.currentGroup = self.hand
    end
  end
      
  
end
return Player
