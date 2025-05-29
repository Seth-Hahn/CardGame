--card class--
local class = require 'libraries/middleclass'

local Card = class('Card')

function Card:initialize(name, cost, power, effectTrigger, effect)
  self.name = name
  self.cost = cost
  self.power = power
  self.effect = effect
  self.effectTrigger = effectTrigger
  self.front = love.graphics.newImage("assets/img/" .. name .. ".png")
  self.back = love.graphics.newImage("assets/img/cardBack.png")
  
  self.x = nil
  self.y = nil
  self.width = self.front:getWidth()
  self.height = self.front:getHeight()
  
  self.isFaceUp = false
  self.currentGroup = nil
  
  self.hasBeenFlipped = false
end

function Card:setLocation(xPos, yPos)
  self.x = xPos
  self.y = yPos
end

function Card:drawToScreen()
  if self.isFaceUp == true then
    love.graphics.draw(self.front, self.x, self.y)
  else
    love.graphics.draw(self.back, self.x, self.y)
  end
end


function Card:moveFromTo(originalLocation, destination, cardOwner)
  if destination.holderType == 'Location 1' or destination.holderType == 'Location 2' or destination.holderType == 'Location 3' then
    if #destination.cards < 4 then --only 4 cards per location
      for i = #originalLocation.cards, 1, -1 do
        if originalLocation.cards[i] == self then --find the card in its group and remove it
          table.remove(originalLocation.cards, i)
          break
        end
      end
      local newX = destination.emptyRectangleCoords[#destination.emptyRectangleCoords - #destination.cards][1]
      local newY = destination.emptyRectangleCoords[#destination.emptyRectangleCoords - #destination.cards][2]
      self:setLocation(newX, newY)
      self.currentGroup = destination
      table.insert(destination.cards, #destination.cards + 1, self)
      destination.totalPower = destination.totalPower + self.power
    end
  end
  
  if destination.holderType == 'DiscardPile' then
    for i = 4, 1, -1 do
        if originalLocation.cards[i] == self then --find the card in its group and remove it
          table.remove(originalLocation.cards, i)
          break
        end
      end
      
    if originalLocation.totalPower ~= nil then --remove cards power from its played location
      originalLocation.totalPower = originalLocation.totalPower - self.power
    end
    
    local newX = destination.x --update location of cards
    local newY = destination.y
    self:setLocation(newX,newY)
    self.currentGroup = destination
    table.insert(destination.cards, #destination.cards + 1, self)
  end
    
    
end

function Card:noEffect(player, opponent)
  print('vanilla')
  return
end

function Card:zeusEffect(player, opponent) -- -1 power for each card in opponents hand
  for i = 1, #opponent.hand.cards, 1 do
    cardToDebuff = opponent.hand.cards[i]
    cardToDebuff.power = cardToDebuff.power - 1
  end
  return
end

function Card:medusaEffect(player, opponent)
  return
end

function Card:artemisEffect(player, opponent) -- gain +5 power if there is exactly one enemy card in this location
  local artemisCurrentGroup = self.currentGroup.holderType
  local playLocationsForOpponent = {opponent.playLocationOne, opponent.playLocationTwo,opponent.playLocationThree}
  local opposingLocation = nil
  
  for i = 1, #playLocationsForOpponent, 1 do
    if artemisCurrentGroup == playLocationsForOpponent[i].holderType then
      opposingLocation = playLocationsForOpponent[i]
      break
    end
  end
  
  
  if opposingLocation ~= nil then
    if #opposingLocation.cards == 1 then
      self.power = self.power + 5
      self.currentGroup.totalPower = self.currentGroup.totalPower + 5
    end
  end
  
  return
end

function Card:swordOfDamoclesEffect(player, opponent)
  return
end

function Card:cyclopsEffect(player, opponent) --discard player's other cards in this location, gain +2 power for each discarded card
  for i = 4, 1, -1 do
    local cardToDiscard = self.currentGroup.cards[i]
    if cardToDiscard ~= self and cardToDiscard ~= nil then
      cardToDiscard:moveFromTo(cardToDiscard.currentGroup, player.discardPile, player)
      self.power = self.power + 2
    end
  end
  
  self.currentGroup.totalPower = self.power 
    
  --move cyclops to the top position of its group
  local newX = self.currentGroup.emptyRectangleCoords[4][1]
  local newY = self.currentGroup.emptyRectangleCoords[4][2]
  self:setLocation(newX, newY)
end

function Card:heliosEffect(player, opponent)
  return
end

return Card
  