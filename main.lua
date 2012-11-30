--[[
  Tower Engineer - A simple 2D game where you have to make towers
]]--

function love.load()
  -- love.physics.setMeter(64)
  world = love.physics.newWorld(0, 9.8 * 64, true)
  blocks = {}
  canAddBlock = true
  newBlock = {width = 150, height = 20}

  -- Set up score
  love.filesystem.setIdentity("tower_engineer")
  if not love.filesystem.isFile("data") then
    love.filesystem.write("data", "0", 2)
  end

  local contents, length = love.filesystem.read("data", 2)
  maxScore = tonumber(contents)

  -- Create the ground
  ground = {}
  ground.body = love.physics.newBody(world, 650 / 2, 700 - 50 / 2)
  ground.shape = love.physics.newRectangleShape(650, 50)
  ground.fixture = love.physics.newFixture(ground.body, ground.shape)

  -- Set up graphics
  love.graphics.setBackgroundColor(104, 136, 248)
  love.graphics.setMode(650, 700, false, true, 0)

  -- Load font
  love.graphics.setNewFont(20)
end

function love.update(dt)
  world:update(dt)

  -- Add new blocks
  if love.mouse.isDown("l") then
    if canAddBlock then
      local block = {}
      block.body = love.physics.newBody(world, love.mouse.getX(), love.mouse.getY(), "dynamic")
      block.shape = love.physics.newRectangleShape(0, 0, newBlock.width, newBlock.height)
      block.height = newBlock.height
      block.fixture = love.physics.newFixture(block.body, block.shape, 100)
      block.fixture:setRestitution(0)
      
      if #blocks ~= 1 then
        newBlock.width = math.random(5, 100)
        newBlock.height = math.random(5, 40)
      end
      
      table.insert(blocks, block)
      canAddBlock = false
    end
  else
    canAddBlock = true
  end

  -- Check if player lost
  local blocksOnGround = 0
  for i = 1, #blocks do

    if blocks[i].body:getY() + blocks[i].height > 650 then
      blocksOnGround = blocksOnGround + 1
    end
  end

  if blocksOnGround > 1 then
    love.filesystem.write("data", tostring(maxScore), 2)

    love.load()
  end

  -- Update maximum score
  if #blocks > maxScore then
    maxScore = #blocks
  end

  -- Restart game
  if love.keyboard.isDown("r") then
    love.load()
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
  love.graphics.setColor(50, 50, 50)
  for i = 1, #blocks do
    love.graphics.polygon("fill", blocks[i].body:getWorldPoints(blocks[i].shape:getPoints()))
  end

  -- Draw next block
  love.graphics.setColor(255, 240, 240, 50)
  love.graphics.rectangle("fill", love.mouse.getX() - newBlock.width / 2, love.mouse.getY() - newBlock.height / 2, newBlock.width, newBlock.height)

  -- Draw the score
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(#blocks, 10, 8)
  love.graphics.print(maxScore, 10, 35)

  -- Draw welcome message
  if #blocks == 0 then
    love.graphics.print("Left click to insert a block.\nTry to make a huge tower.", 200, 400)
  end
end