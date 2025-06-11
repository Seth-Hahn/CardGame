--discardPile class--
local class = require 'libraries/middleclass'
local CardHolder = require 'classes/CardHolder'

PlayLocation = class('PlayLocation', CardHolder)

function PlayLocation:initialize(xPos, yPos, Location, owner)
  CardHolder.initialize(self, xPos, yPos, Location)
  self.emptyRectangleCoords = {}
  self.owner = owner
  self.totalPower = 0
  self.debuff = nil
  self.debuffer = nil
  self.buff = nil
  self.buffer = nil
end

function PlayLocation:drawToScreen()
  --create rectangle to show card holder position if no card is in slot
  for i = 1, 4, 1 do
    local horizontalOffset = 0
    if i == 2 or i == 4 then
      horizontalOffset = 70
    end
    
    if self.cards[i] == nil then
      love.graphics.setColor(0, 0, 0)
      local holderGraphic = love.graphics.rectangle('line', self.x + horizontalOffset, self.y + (70*i), self.width, self.height)
      if #self.emptyRectangleCoords < 4 then 
        table.insert(self.emptyRectangleCoords, 1, {self.x + horizontalOffset, self.y + (70*i)} )
      end
      love.graphics.setColor(255,255,255)
    else 
      self.cards[i]:drawToScreen()
    end
  end
  
  if self.owner.isAI ~= true then 
    love.graphics.print(self.holderType, self.x , self.y + 325)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height / 3)
    love.graphics.print('DRAG HERE TO PLACE', self.x, self.y + (self.y / 10) )
  end
  love.graphics.print("Power:" .. self.totalPower, self.x, self.y + 340)
end

return PlayLocation