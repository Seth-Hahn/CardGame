--card class--
local class = require 'libraries/middleclass'

local Card = class('Card')

function Card:initialize(name, cost, power, effectTrigger, effect)
  self.name = name
  self.cost = cost
  self.power = power
  self.usualPowerLevel = power
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
      
      --apply any location debuffs to cards played
      if destination.debuff == 'medusa' and destination.debuffer.currentGroup.holderType ~= "DiscardPile" then
        self.power = self.power - 1
        destination.totalPower = destination.totalPower + self.power
      else --standard case AKA no debuffs
        destination.totalPower = destination.totalPower + self.power
      end
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
      if originalLocation.totalPower < 0 then --location power cannot go negative
        originalLocation.totalPower = 0
      end
    end
    
    local newX = destination.x --update location of cards
    local newY = destination.y
    self:setLocation(newX,newY)
    self.currentGroup = destination
    table.insert(destination.cards, #destination.cards + 1, self)
    
    if self.effectTrigger == "onDiscard" then
      self.effect(self, cardOwner, cardOwner.opposingPlayer)
    end
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

function Card:medusaEffect(player, opponent) --any card played in Medusa's location recieves -1 to power stat
  local medusaCurrentGroup = self.currentGroup.holderType
  local playLocationsForOpponent = {opponent.playLocationOne, opponent.playLocationTwo,opponent.playLocationThree}
  local opposingLocation = nil
  
  for i = 1, #playLocationsForOpponent, 1 do
    if medusaCurrentGroup == playLocationsForOpponent[i].holderType then
      opposingLocation = playLocationsForOpponent[i]
      break
    end
  end
  if opposingLocation ~= nil then 
    opposingLocation.debuff = "medusa"
    opposingLocation.debuffer = self
  end
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

function Card:swordOfDamoclesEffect(player, opponent) -- lose 1 power if not winning this location
  local damoclesCurrentGroup = self.currentGroup.holderType
  local playLocationsForOpponent = {opponent.playLocationOne, opponent.playLocationTwo,opponent.playLocationThree}
  local opposingLocation = nil
  
  for i = 1, #playLocationsForOpponent, 1 do
    if damoclesCurrentGroup == playLocationsForOpponent[i].holderType then
      opposingLocation = playLocationsForOpponent[i]
      break
    end
  end
  
  if opposingLocation ~= nil then
    if opposingLocation.totalPower >= self.currentGroup.totalPower then
      self.currentGroup.totalPower = self.currentGroup.totalPower - self.power
      self.power = self.power - 1
      self.currentGroup.totalPower = self.currentGroup.totalPower + self.power
    end
  end
  
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
  if self.currentGroup.emptyRectangleCoords ~= nil then
    local newX = self.currentGroup.emptyRectangleCoords[4][1]
    local newY = self.currentGroup.emptyRectangleCoords[4][2]
    self:setLocation(newX, newY)
  end
end

function Card:heliosEffect(player, opponent) --discard this card at end of turn
  self:moveFromTo(self.currentGroup, player.discardPile, player)
  return
end

function Card:nyxEffect(player, opponent) --discard other cards in this location and add power to this card
  for i = 4, 1, -1 do
    local cardToDiscard = self.currentGroup.cards[i]
    if cardToDiscard ~= self and cardToDiscard ~= nil then
      cardToDiscard:moveFromTo(cardToDiscard.currentGroup, player.discardPile, player)
      self.power = self.power + cardToDiscard.power
    end
  end
  
    self.currentGroup.totalPower = self.power 
    
  --move nyx to the top position of its group
  if self.currentGroup.emptyRectangleCoords ~= nil then
    local newX = self.currentGroup.emptyRectangleCoords[4][1]
    local newY = self.currentGroup.emptyRectangleCoords[4][2]
    self:setLocation(newX, newY)
  end
  return
end

function Card:icarusEffect(player, opponent) --gain +1 power end of turn; discard when power is greater than 7
  if self.currentGroup.totalPower ~= nil then 
    self.currentGroup.totalPower = self.currentGroup.totalPower - self.power
    self.power = self.power + 1
    self.currentGroup.totalPower = self.currentGroup.totalPower + self.power
  end
  if self.power > 7 then
    self:moveFromTo(self.currentGroup, player.discardPile, player)
  end
end

function Card:hydraEffect(player, opponent) --add two copies to your hand when this card is discarded
  for i = 1, 2, 1 do
    local newHydra = Card('hydra', 1,3,'onDiscard', self.effect)
    if #player.hand.cards < 7 then
      table.insert(player.referenceToGameObjectList, newHydra)
      table.insert(player.drawDeck.cards, newHydra)
      player:drawToHand()
    end
  end
end

function Card:herculesEffect(player, opponent) --double power if this is the strongest card within player location
  for i = 4, 1, -1 do
    local cardToCheck = self.currentGroup.cards[i] --check each card in this location's power
    if cardToCheck ~= self and cardToCheck ~= nil then
      if cardToCheck.power > self.power then --if any card is stronger, than do nothing
        return
      end
    end
  end
  
  self.currentGroup.totalPower = self.currentGroup.totalPower - self.power
  self.power = self.power * 2
  self.currentGroup.totalPower = self.currentGroup.totalPower + self.power
  return 
end
return Card
  