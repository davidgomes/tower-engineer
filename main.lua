--[[
  Tower Engineer - A simple 2D game where you have to make towers
]]--

function love.load()
  currentState = "play"
  world = love.physics.newWorld(0, 9.8 * 64, true)
  world:setCallbacks(beginContact, nil, nil, nil)
  numberOfCollisions = 0

  blocks = {}
  canAddBlock = true
  newBlock = {width = 200, height = 20}
  nextBlock = {width = math.random(5, 100), height = math.random(5, 30)}

  -- Set up score
  love.filesystem.setIdentity("tower_engineer")
  if not love.filesystem.isFile("data") then
    love.filesystem.write("data", "0", 2)
  end

  local contents, length = love.filesystem.read("data", 2)
  maxScore = tonumber(contents)

  -- Create the ground
  ground = {}
  ground.body = love.physics.newBody(world, 650 / 2, 700 - 50 / 2, "static")
  ground.shape = love.physics.newRectangleShape(650 * 2, 50)
  ground.fixture = love.physics.newFixture(ground.body, ground.shape)
  ground.fixture:setUserData("ground")

  -- Set up graphics
  love.graphics.setBackgroundColor(104, 136, 248)
  love.graphics.setMode(650, 700, false, true, 0)

  -- Load font
  love.graphics.setNewFont(20)
end

function love.update(dt)
  if currentState == "play" then
    world:update(dt)

    -- Add new blocks
    if love.mouse.isDown("l") then
      if canAddBlock then
        local block = {}
        block.color = {math.random(40, 60), math.random(40, 60), math.random(40, 60)}
        block.body = love.physics.newBody(world, love.mouse.getX(), love.mouse.getY(), "dynamic")
        block.shape = love.physics.newRectangleShape(0, 0, newBlock.width, newBlock.height)
        block.height = newBlock.height
        block.fixture = love.physics.newFixture(block.body, block.shape, 100)
        block.fixture:setRestitution(0)

        newBlock.width, newBlock.height = nextBlock.width, nextBlock.height

        nextBlock.width = math.random(5, 100)
        nextBlock.height = math.random(5, 30)

        table.insert(blocks, block)
        canAddBlock = false
      end
    else
      canAddBlock = true
    end

    -- Check if player lost
    if numberOfCollisions > 1 then
      love.filesystem.write("data", tostring(maxScore), 2)

      currentState = "over"
    end

    -- Update maximum score
    if #blocks > maxScore then
      maxScore = #blocks
    end
  elseif currentState == "over" then
    if love.mouse.isDown("l") then
      love.load()
    end
  end

  -- Exit the game
  if love.keyboard.isDown("escape") then
    love.event.quit()
  end
end

function love.draw()
  -- Draw the ground
  love.graphics.setColor(72, 160, 14)
  love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

  -- Draw the blocks
  for i = 1, #blocks do
    love.graphics.setColor(blocks[i].color)
    love.graphics.polygon("fill", blocks[i].body:getWorldPoints(blocks[i].shape:getPoints()))
  end

  if currentState == "play" then
    -- Draw block
    love.graphics.setColor(255, 240, 240, 70)
    love.graphics.rectangle("fill", love.mouse.getX() - newBlock.width / 2, love.mouse.getY() - newBlock.height / 2, newBlock.width, newBlock.height)

    -- Draw next block
    love.graphics.setColor(255, 240, 240, 15)
    love.graphics.rectangle("fill", love.mouse.getX() - nextBlock.width / 2, love.mouse.getY()- nextBlock.height / 2 - 100, nextBlock.width, nextBlock.height)
  end

  -- Draw the score
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(#blocks, 10, 8)
  love.graphics.print(maxScore, 10, 35)

  -- Draw welcome message
  if #blocks == 0 then
    love.graphics.print("Left click to insert a block.\nTry to make a huge tower.", 200, 400)
  end

  if currentState == "over" then
    love.graphics.print("Game Over", 265, 50)
    love.graphics.setBlendMode("multiplicative")
  else
    love.graphics.setBlendMode("alpha")
  end
end

function beginContact(a, b, collision)
  if a:getUserData() == "ground" or b:getUserData() == "ground" then
    numberOfCollisions = numberOfCollisions + 1
  end
end