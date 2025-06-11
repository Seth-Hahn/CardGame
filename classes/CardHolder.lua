local class = require 'libraries/middleclass'

--cardholder base class
local CardHolder = class('CardHolder')


function CardHolder:initialize(xPos, yPos, holderType)
  self.x = xPos
  self.y = yPos
  self.holderType = holderType
  self.width = 60
  self.height = 100
  self.cards = {}
end


function CardHolder:drawToScreen() 
  --create rectangle to show card holder position if column is empty
  if #self.cards == 0 then
    love.graphics.setColor(0, 0, 0)
    local holderGraphic = love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    love.graphics.setColor(255,255,255)
  else
    for i = 1, #self.cards, 1 do
      self.cards[i]:drawToScreen()
    end
  end
  
  love.graphics.print(self.holderType, self.x, self.y +100)
end

function CardHolder:clickedOn()
end
return CardHolder

