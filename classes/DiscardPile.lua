--discardPile class--
local class = require 'libraries/middleclass'
local CardHolder = require 'classes/CardHolder'

DiscardPile = class('DiscardPile', CardHolder)

function DiscardPile:initialize(xPos, yPos)
  CardHolder.initialize(self, xPos, yPos, 'DiscardPile')
end

return DiscardPile