--drawDeck class--
local class = require 'libraries/middleclass'
local CardHolder = require 'classes/CardHolder'

DrawDeck = class('DrawDeck', CardHolder)

function DrawDeck:initialize(xPos, yPos)
  CardHolder.initialize(self, xPos, yPos, 'DrawDeck')
end

-- Table shuffle based on code found at : https://stackoverflow.com/questions/35572435/how-do-you-do-the-fisher-yates-shuffle-in-lua
function DrawDeck:shuffleDeck()
  for i = #self.cards, 2, -1 do
    local j = math.random(i)
    self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
  end
end

return DrawDeck