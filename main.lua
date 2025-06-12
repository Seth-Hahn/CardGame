local CardHolder = require "classes/CardHolder"
local PlayerClass = require "classes/Player"
local AIClass = require "classes/AI"
local Card = require "classes/Card"
local SubmitButton = require "classes/SubmitButton"
local ResetButton = require "classes/resetButton"
local DifficultyButton = require "classes/DifficultyButton"
local UndoButton = require "classes/UndoButton"
local PlayButton = require "classes/PlayButton"
local BuildDeckButton = require "classes/BuildDeckButton"
require "libraries/middleclass"



--global variables--
drawableObjects = {}
screenWidth, screenHeight = love.window.getDesktopDimensions()
turnNumber = 1
turnSubmitted = nil
otherPlayerTurnToFlip = false
numPlayersWithFlippedCards = 0
flipInterval = 0.6
pointsToWin = 25
winnerSelected = false
winner = nil
difficultyLevel = 1
onTitleScreen = true
onDeckBuilderScreen = false
numCardsPicked = 0
builtDeck = {}

--love functions--
function love.load()
  screenSetup()
  --seed random number generator for deck shuffle
  math.randomseed(os.time())
  math.random() math.random() math.random() --shuffle the randomizer a few times
  
  --initialize AI and player decks--
  Player = PlayerClass(screenWidth / 2, screenHeight / 2)
  Player:setupDeck()
  addPlayerCardHoldersToObjectList(Player)
  Player:drawToHand(turnNumber)
  Player.referenceToGameObjectList = drawableObjects
  
  AI = AIClass(screenWidth / 2, screenHeight / 100, difficultyLevel)
  AI:setupDeck()
  addPlayerCardHoldersToObjectList(AI)
  AI:drawToHand(turnNumber)
  
  --set Player and AI as opponents
  Player.opposingPlayer = AI
  AI.opposingPlayer = Player
  
  
end

function love.draw() 
  if not onTitleScreen or not onDeckBuilderScreen then
    love.graphics.draw(background)
    Player:drawToScreen()
    AI:drawToScreen()
    submitButton:drawToScreen()
    resetButton:drawToScreen()
    easyButton:drawToScreen()
    mediumButton:drawToScreen()
    hardButton:drawToScreen()
    undoButton:drawToScreen()
  end
  
  if winnerSelected == true and winner ~= nil then
    local standardFont = love.graphics.getFont()
    local bigFont = love.graphics.newFont(48)
    love.graphics.setFont(bigFont)
    love.graphics.print(winner.tag .. " has Won!", screenWidth / 2, screenHeight / 2)
    love.graphics.setFont(standardFont)
  end
  
  if onTitleScreen == true then
    love.graphics.draw(titleScreen)
    if onDeckBuilderScreen == false then
      playButton:drawToScreen()
      buildDeckButton:drawToScreen()
    end
  end
  
  if onDeckBuilderScreen == true then
    local standardFont = love.graphics.getFont()
    local bigFont = love.graphics.newFont(48)
    love.graphics.setFont(bigFont)
    love.graphics.print(#builtDeck .. " / 20", screenWidth / 2, screenHeight * .8)
    love.graphics.setFont(standardFont)
    local wholeSetCardHolder = {}
    for i = 1, #Player.drawDeck.cards, 1 do
      table.insert(wholeSetCardHolder, Player.drawDeck.cards[i])
    end
    for i = 1, #Player.hand.cards, 1 do
      table.insert(wholeSetCardHolder, Player.hand.cards[i])
    end
    
    local numCardsDrawn = 1
    for row = 1, 5, 1 do
      for column = 1, 9, 1 do
        if wholeSetCardHolder[numCardsDrawn] ~= nil then
          local card = wholeSetCardHolder[numCardsDrawn]
          card:setLocation((screenWidth*.1)+ (column * 150), screenHeight * .05 + (row * 150))
          card.isFaceUp = true
          card:drawToScreen()
          numCardsDrawn = numCardsDrawn + 1
        end
      end
    end
    
  end
    
end

function love.update(dt)
  --handle deck builder 
  if onDeckBuilderScreen and #builtDeck == 20 then 
    onDeckBuilderScreen = false
    onTitleScreen = false
    for i = #Player.drawDeck.cards, 1, -1 do
      Player.drawDeck.cards[i].currentGroup = nil
      Player.drawDeck.cards[i] = nil
    end
    for i = #Player.hand.cards, 1, -1 do 
      Player.hand.cards[i].currentGroup = nil
      Player.hand.cards[i] = nil
    end
      
    for i = 1, #builtDeck, 1 do
      local card = builtDeck[i]
        card:setLocation(Player.drawDeck.x, Player.drawDeck.y - (Player.drawDeck.y / 20) )
        card.isFaceUp = false
        table.insert(Player.drawDeck.cards, 1, card)
        card.currentGroup = Player.drawDeck
    end
    Player.drawDeck:shuffleDeck()
    Player:drawToHand(turnNumber)
  end
  --handle card effects that run while the card is active
  --do on turn end effects for any cards which have been played
  for i = #Player.playedCards, 1, -1 do
    local cardToCheck = Player.playedCards[i]
    if cardToCheck.effectTrigger == "whileActive" and cardToCheck.isFaceUp then
      cardToCheck.effect(cardToCheck, Player, AI)
    end
  end
      
  for i = #AI.playedCards, 1, -1 do 
    local cardToCheck = AI.playedCards[i]
    if cardToCheck.effectTrigger == "whileActive" and cardToCheck.isFaceUp then
      cardToCheck.effect(cardToCheck, AI, Player)
    end
  end
  
  
  if turnSubmitted == true then
    local turnWinner,turnWinnerPointsGained, turnLoser, turnLoserPointsGained = determineTurnWinner(Player, AI) 
    if otherPlayerTurnToFlip ~= true then
      flipCards(turnWinner, turnLoser, dt)
    else
      flipCards(turnLoser,turnWinner, dt)
    end
    
    if numPlayersWithFlippedCards == 2 then --turn end
      numPlayersWithFlippedCards = 0
      turnSubmitted = false
      turnNumber = turnNumber + 1
      Player.mana = turnNumber
      AI.mana = turnNumber
      otherPlayerTurnToFlip = false
      turnWinner.points = turnWinner.points + turnWinnerPointsGained
      turnLoser.points = turnLoser.points + turnLoserPointsGained
      
      --do on turn end effects for any cards which have been played
      for i = #Player.playedCards, 1, -1 do
        local cardToCheck = Player.playedCards[i]
        if cardToCheck.effectTrigger == "onTurnEnd" then
          cardToCheck.effect(cardToCheck, Player, AI)
        end
      end
      
      for i = #AI.playedCards, 1, -1 do 
        local cardToCheck = AI.playedCards[i]
        if cardToCheck.effectTrigger == "onTurnEnd" then
          cardToCheck.effect(cardToCheck, AI, Player)
        end
      end
      
      local GameWinner = determineGameWinner(Player, AI)
      if GameWinner ~= nil then
        winnerSelected = true
        winner = GameWinner
        
      end
      
      for i = 1, #Player.hand.cards, 1 do --put players hand in order of grabbed cards
        Player.hand.cards[i]:setLocation(Player.hand.x + (i * 70), Player.hand.y)
      end
      Player:drawToHand(turnNumber)
      AI:drawToHand(turnNumber)
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
      --logic for deckBuilder
      if onDeckBuilderScreen and selectedObject.isPlayingCard then
        table.insert(builtDeck, selectedObject)
      end
      
      --logic for clicking the submit button
      if selectedObject.isSubmitButton then
        submitTurn()
        return
      end
      if selectedObject.isResetButton then
        resetGame()
        return
      end
      if selectedObject.isDifficultyButton then
        AI.difficulty = selectedObject.difficultyLevel
        return
      end
      if selectedObject.isUndoButton then
        undoStage()
        return
      end
      
      if selectedObject.isPlayButton then
        onTitleScreen = false
      end
      
      if selectedObject.isBuildDeckButton then
        onDeckBuilderScreen = true
      end
      
      --logic for placing a card down
      if selectedObject ~= nil and selectedObject.isFaceUp then
        
        --determine which object the card is being placed on
        for i = 1, #drawableObjects, 1 do
          if clickOnObject(mx,my, drawableObjects[i]) then
            if drawableObjects[i] == Player.playLocationOne or --cards must be placed in one of the three play locations
              drawableObjects[i] == Player.playLocationTwo or
              drawableObjects[i] == Player.playLocationThree then
                
                if Player.mana >= selectedObject.cost then --cards only playable when there is enough mana
                  selectedObject:moveFromTo(selectedObject.currentGroup, drawableObjects[i], Player, turnNumber)
                  Player.mana = Player.mana - selectedObject.cost
                  table.insert(Player.playedCards, selectedObject)
                end
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

function undoStage() --go through each holder and put cards which were just placed back into the hand
  local playLocationsPlayer = {Player.playLocationOne, Player.playLocationTwo, Player.playLocationThree}
  for i = 1, 3, 1 do
    local currentLocation = playLocationsPlayer[i].cards
    for i = #currentLocation, 1, -1 do
      local card = currentLocation[i]
      if card.turnPlayed == turnNumber then
        card:moveFromTo(card.currentGroup, Player.hand, Player, turnNumber)
        for i = #Player.playedCards, 1, -1 do
          if Player.playedCards[i] == card then -- take card out of played cards group
            table.remove(Player.playedCards, i)
          end
        end
      end
    end
  end
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

function flipCards(player,opponent, dt)
  player.flipTimer = player.flipTimer + dt
  
  if player.flipIndex <= #player.playedCards and player.playedCards[player.flipIndex].isFaceUp then --dont wait for cards which have already been flipped
    player.flipTimer = flipInterval
  end
  
  if player.flipTimer >= flipInterval and player.flipIndex <= #player.playedCards then
    local card = player.playedCards[player.flipIndex]
    card.isFaceUp = true
    if card.effectTrigger == "onReveal" and card.hasBeenFlipped ~= true then
      card.effect(card, player, opponent)
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

function determineTurnWinner(player, opponent)
  local playerPlayLocations = {player.playLocationOne, player.playLocationTwo, player.playLocationThree}
  local playerTotalPower = 0
  
  local opponentPlayLocations = {opponent.playLocationOne, opponent.playLocationTwo, opponent.playLocationThree}
  local opponentTotalPower = 0
  
  for i = 1, 3, 1 do --iterate through opposing player locations and determine total power of each
    local playerLocation = playerPlayLocations[i]
    local opponentLocation = opponentPlayLocations[i]
    if playerLocation.totalPower > opponentLocation.totalPower then --player has more power at a location, give them the mana
      playerTotalPower = playerTotalPower + (playerLocation.totalPower - opponentLocation.totalPower)
    elseif opponentLocation.totalPower > playerLocation.totalPower then
      opponentTotalPower = opponentTotalPower + (opponentLocation.totalPower - playerLocation.totalPower)
    end
  end
  if playerTotalPower > opponentTotalPower then --player won the round
    return player, playerTotalPower, opponent, opponentTotalPower
  elseif opponentTotalPower > playerTotalPower then --opponent won the round
    return opponent, opponentTotalPower, player, playerTotalPower
  elseif playerTotalPower == opponentTotalPower then --equal power on both sides
    coinflip = love.math.random(1,2)
    if coinflip == 1 then
      return player, playerTotalPower, opponent, opponentTotalPower
    else
      return opponent, opponentTotalPower, player, playerTotalPower
    end
  end
end

function determineGameWinner(player, opponent)
  local numWinners = 0 --both players can reach more than the required points on the same turn
  local winner = nil
  
  if player.points >= pointsToWin then
    winner = player
    numWinners = numWinners + 1
  end
  
  if opponent.points >= pointsToWin then
    winner = opponent
    numWinners = numWinners + 1
  end
  
  if numWinners == 2 then --both players reach N points, whoever has more wins
    if player.points > opponent.points then
      winner = player
    else
      winner = opponent
    end
  end
  
  return winner
    
end

function resetGame()
  --reset all global variables then call load
  drawableObjects = {}
  screenWidth, screenHeight = love.window.getDesktopDimensions()
  turnNumber = 1
  turnSubmitted = nil
  otherPlayerTurnToFlip = false
  numPlayersWithFlippedCards = 0
  flipInterval = 0.6
  pointsToWin = 25
  winnerSelected = false
  winner = nil
  onTitleScreen = true
  onDeckBuilderScreen = false
  numCardsPicked = 0
  builtDeck = {}
  
  --reset player and AI
  
  
  love.load()
  return
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
  -- load title screen and associated buttons
  titleScreen = love.graphics.newImage("assets/img/titleScreen.png")
  playButton = PlayButton(screenWidth / 2, screenHeight * .6)
  buildDeckButton = BuildDeckButton(screenWidth / 2, screenHeight * .7)
  table.insert(drawableObjects, 1, playButton)
  table.insert(drawableObjects, 1, buildDeckButton)
  
  -- load green background
  background = love.graphics.newImage("assets/img/solitaireBackground.png")
  
  --load submit button
  submitButton = SubmitButton(screenWidth / 10, screenHeight /2)
  table.insert(drawableObjects, 1, submitButton)
  
  --load Reset Button
  resetButton = ResetButton(screenWidth / 10, screenHeight / 4)
  table.insert(drawableObjects, 1, resetButton)
  
  --load difficulty buttons
  easyButton = DifficultyButton(screenWidth * .9 , screenHeight * .2, "easyButton", 1)
  table.insert(drawableObjects, 1, easyButton)
  mediumButton = DifficultyButton(screenWidth * .9, screenHeight * .3, "mediumButton", 2)
  table.insert(drawableObjects, 1, mediumButton)
  hardButton = DifficultyButton(screenWidth * .9, screenHeight * .4, "hardButton", 3)
  table.insert(drawableObjects, 1, hardButton)
  
  --load undo button
  undoButton = UndoButton(screenWidth * .2, screenHeight  *.8)
  table.insert(drawableObjects, 1, undoButton)
end
