local CardHolder = require "classes/CardHolder"
local Player = require "classes/Player"
local AI = require "classes/AI"
local Card = require "classes/Card"
local SubmitButton = require "classes/SubmitButton"
require "libraries/middleclass"


--global variables--
drawableObjects = {}
screenWidth, screenHeight = love.window.getDesktopDimensions()
turnNumber = 1
turnSubmitted = nil
otherPlayerTurnToFlip = false
numPlayersWithFlippedCards = 0
flipInterval = 0.6

--love functions--
function love.load()
  screenSetup()
  --seed random number generator for deck shuffle
  math.randomseed(os.time())
  math.random() math.random() math.random() --shuffle the randomizer a few times
  
  --initialize AI and player decks--
  Player = Player(screenWidth / 2, screenHeight / 2)
  Player:setupDeck()
  addPlayerCardHoldersToObjectList(Player)
  Player:drawToHand(turnNumber)
  
  AI = AI(screenWidth / 2, screenHeight / 100)
  AI:setupDeck()
  addPlayerCardHoldersToObjectList(AI)
  AI:drawToHand(turnNumber)
  
end

function love.draw() 
  love.graphics.draw(background)
  Player:drawToScreen()
  AI:drawToScreen()
  submitButton:drawToScreen()
end

function love.update(dt)
  if turnSubmitted == true then
    flipCards(Player, dt)
    if otherPlayerTurnToFlip then
      flipCards(AI, dt)
    end
    
    if numPlayersWithFlippedCards == 2 then
      numPlayersWithFlippedCards = 0
      turnSubmitted = false
    end
  end
end
  
function love.mousepressed(mx, my, button)
  if button == 1 then
    isMouseDown = true
    selectedObject = nil
    isDragging = false
    
    --iterate through all objects to determine which one was selected
    for i = 1, #drawableObjects, 1 do
      if clickOnObject(mx, my, drawableObjects[i]) then 
          selectedObject = drawableObjects[i]
          selectedObjectOriginalX = selectedObject.x
          selectedObjectOriginalY = selectedObject.y
      end
    end

    if selectedObject ~= nil then 
      isDragging = true
    end
  end
end
 
function love.mousemoved(mx, my)
  --update card location to follow mouse pointer
  if selectedObject ~= nil and selectedObject.isFaceUp and isDragging then
    selectedObject:setLocation(mx, my)
  end
end

function love.mousereleased(mx,my,button)
  if button == 1 then
    isDragging = false
    
    if selectedObject ~= nil then
      --logic for clicking the submit button
      if selectedObject.isSubmitButton then
        submitTurn()
        return
      end
      
      --logic for placing a card down
      if selectedObject ~= nil and selectedObject.isFaceUp then
        
        --determine which object the card is being placed on
        for i = 1, #drawableObjects, 1 do
          if clickOnObject(mx,my, drawableObjects[i]) then
            if drawableObjects[i] == Player.playLocationOne or --cards must be placed in one of the three play locations
              drawableObjects[i] == Player.playLocationTwo or
              drawableObjects[i] == Player.playLocationThree then
                --put card into selected group
                selectedObject:moveFromTo(selectedObject.currentGroup, drawableObjects[i], Player)
                Player.mana = Player.mana - selectedObject.cost
                table.insert(Player.playedCards, selectedObject)
            else
                selectedObject:setLocation(selectedObjectOriginalX, selectedObjectOriginalY)
            end
          end
        end
      end
    end
  end
  selectedObject = nil 
end
    
  
    
 
 
 
 
  --game functions--
--determines if something in the game was clicked on
function clickOnObject(mx, my, object)
  return mx >= object.x and mx <= object.x + object.width and
  my >= object.y and my <= object.y + object.height
end 

function submitTurn()
  local playLocationsPlayer = {Player.playLocationOne, Player.playLocationTwo, Player.playLocationThree}
  
  --flip player cards face down
  for i = 1, 3, 1 do
    local currentLocation = playLocationsPlayer[i].cards
    for i = 1, #currentLocation, 1 do
      if currentLocation[i].hasBeenFlipped ~= true then 
        currentLocation[i].isFaceUp = false
      end
    end
  end
  
  --ai makes its moves
  AI:takeTurn(turnNumber, playedCards)
  
  --set submitted turn flag for update function
  turnSubmitted = true
end
function addPlayerCardHoldersToObjectList(player)
  table.insert(drawableObjects, 1, player.drawDeck)
  table.insert(drawableObjects, 1, player.discardPile)
  table.insert(drawableObjects, 1, player.hand)
  table.insert(drawableObjects, 1, player.playLocationOne)
  table.insert(drawableObjects, 1, player.playLocationTwo)
  table.insert(drawableObjects, 1, player.playLocationThree)
  
  for i = 1, #player.drawDeck.cards, 1 do
    table.insert(drawableObjects, 1, player.drawDeck.cards[i])
  end
end

function flipCards(player, dt)
  player.flipTimer = player.flipTimer + dt
  
  if player.flipTimer >= flipInterval and player.flipIndex <= #player.playedCards then
    local card = player.playedCards[player.flipIndex]
    card.isFaceUp = true
    if card.effectTrigger == "onReveal" and card.hasBeenFlipped ~= true then
      card.effect(card, Player, AI)
    end
    card.hasBeenFlipped = true
    
    player.flipIndex = player.flipIndex + 1
    player.flipTimer = player.flipTimer - flipInterval
  end
  
  if player.flipIndex == #player.playedCards + 1 then
    player.flipIndex = 1
    numPlayersWithFlippedCards = numPlayersWithFlippedCards + 1
    otherPlayerTurnToFlip = true
  end
end


  
  
  
  
  
  
  --miscellaneous functions--

--sets up game window
function screenSetup() 
  --set proper window sizing and title
  love.window.setTitle("Fortnite: The Card Game")
  love.window.setMode(screenWidth, screenHeight, {
      fullscreen = false,
      borderless = false,
      resizable = false
  })
  -- load green background
  background = love.graphics.newImage("assets/img/solitaireBackground.png")
  
  --load submit button
  submitButton = SubmitButton(screenWidth / 10, screenHeight /2)
  table.insert(drawableObjects, 1, submitButton)
end
