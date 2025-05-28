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
end

function Card:noEffect()
  print('vanilla')
  return
end

function Card:zeusEffect()
  print('deus')
  return
end

function Card:medusaEffect()
  return
end

function Card:artemisEffect()
  print('fartemis')
  return
end

function Card:swordOfDamoclesEffect()
  return
end

function Card:cyclopsEffect()
  print('whyclops')
  return
end

function Card:heliosEffect()
  return
end

return Card
  