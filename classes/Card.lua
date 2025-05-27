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

function Card:noEffect()
  return
end

function Card:zeusEffect()
  return
end

function Card:medusaEffect()
  return
end

function Card:artemisEffect()
  return
end

function Card:swordOfDamoclesEffect()
  return
end

function Card:cyclopsEffect()
  return
end

function Card:heliosEffect()
  return
end

return Card
  