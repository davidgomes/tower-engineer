--[[
  Tower Engineer - A simple 2D game where you have to make towers
]]--

function love.load()
  -- love.physics.setMeter(64)
  world = love.physics.newWorld(0, 9.8 * 64, true)
  blocks = {}
  canAddBlock = true

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
end

function love.update(dt)
  world:update(dt)

  -- Add new blocks
  if love.mouse.isDown("l") then
    if canAddBlock then
      newBlock = {}
      newBlock.body = love.physics.newBody(world, love.mouse.getX(), love.mouse.getY(), "dynamic")
      newBlock.shape = love.physics.newRectangleShape(0, 0, 20, 20)
      newBlock.fixture = love.physics.newFixture(newBlock.body, newBlock.shape, 100)

      table.insert(blocks, newBlock)
      canAddBlock = false
    end
  else
    canAddBlock = true
  end

  -- Check if player lost
  local blocksOnGround = 0
  for i = 1, #blocks do

    if blocks[i].body:getY() > 638 then
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
    blocks = {}
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

  -- Draw the score
  love.graphics.print(#blocks, 10, 10)
  love.graphics.print(maxScore, 630, 10)
end