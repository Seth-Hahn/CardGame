--discardPile class--
local class = require 'libraries/middleclass'
local CardHolder = require 'classes/CardHolder'

PlayLocation = class('PlayLocation', CardHolder)

function PlayLocation:initialize(xPos, yPos, Location)
  CardHolder.initialize(self, xPos, yPos, Location)
  for i = 1, 4, 1 do
    self.cards[i] = nil
  end
  self.emptyRectangles = {}
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
      table.insert(self.emptyRectangles, 1, holderGraphic)
      love.graphics.setColor(255,255,255)
    else 
      self.cards[i]:drawToScreen()
    end
  end
  
  love.graphics.print(self.holderType, self.x , self.y + 325)
end

return PlayLocation