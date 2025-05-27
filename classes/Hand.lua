--discardPile class--
local class = require 'libraries/middleclass'
local CardHolder = require 'classes/CardHolder'

Hand = class('Hand', CardHolder)

function Hand:initialize(xPos, yPos)
  CardHolder.initialize(self, xPos, yPos, 'Hand')
  for i = 1, 7, 1 do
    self.cards[i] = nil
  end
end

function Hand:drawToScreen()
  --create rectangle to show card holder position if no card is in slot
  for i = 1, 7, 1 do
    if self.cards[i] == nil then
      love.graphics.setColor(0, 0, 0)
      local holderGraphic = love.graphics.rectangle('line', self.x + (i*70) , self.y, self.width, self.height)
      love.graphics.setColor(255,255,255)
    else
      self.cards[i]:drawToScreen()
    end
  end
  
  love.graphics.print(self.holderType, self.x, self.y + 100)
end

return Hand