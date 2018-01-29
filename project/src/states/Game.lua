--
--  Game
--

local Gamestate     = requireLibrary("hump.gamestate")
local Timer         = requireLibrary("hump.timer")
local Vector        = requireLibrary("hump.vector")
local Camera        = requireLibrary("hump.camera")
local anim8         = requireLibrary("anim8")
--local Timer         = requireLibrary("knife.timer")
local Chain         = requireLibrary("knife.chain")
local Tween         = Timer.tween
local Character     = require 'src/entities/Character'
local Item     = require 'src/entities/Item'
local lume          = requireLibrary("lume")
local WaitForButton = requireLibrary("waitforbutton")
local map
local strength
local cnv
local player
local camera

local screen_msg = nil
local screen_msg_x = 0
local screen_msg_y = 0
local screen_msg_w = 0
local screen_msg_h = 0
local screen_msg_txt_x = 0
local screen_msg_txt_y = 0

local world 

Game = Gamestate.new()

local stuff = {}

local img_chara_player
local img_chara_agent
local player
local last_level

local list_triggers = {}
local list_exit_points = {}
local list_enemySpawner = {}
local sprite_list = {}

local transmissionMessages = {}
local currentTransmissionId = nil
local nextTransmissionRequest = false

local is_accept_enable = true
local function f_isAcceptPressed()
  if  is_accept_enable and keys_pressed['buttona'] then 
    is_accept_enable = false

   -- print(keys_pressed['buttona'])
    -- prevents player from skipping all text by accident
    Timer.after(0.6, function()
      is_accept_enable = true
    end)
    return true
  else
    return false
  end
end


local function sayInBox(msg)
  screen_msg_x = 70
  screen_msg_y = 103
  screen_msg_w = 184
  screen_msg_h = 60
  screen_msg_txt_x = 70 
  screen_msg_txt_y = 103 
  screen_msg = msg
end

local function setLevel(n)
  list_triggers = {}
  list_exit_points = {}
  list_enemySpawner = {}
  sprite_list = {}
  transmissionMessages = {}
  currentTransmissionId = nil

  if last_level==1 then 
    Music.ggj18_theme:stop()
    -- Music.theme:stop()
  elseif n==2 then
    -- Music.theme:stop()
  elseif n==3 then
    -- Music.theme:stop()
  elseif n==4 then
    -- Music.theme:stop()
  elseif n==5 then
    Music.ggj18_ambient:stop()
    Music.ggj18_theme:stop()
    Music.ggj18_theme:play()
  end

  if n==1 then
    map = sti("map/level0.lua", { "box2d" })
    Music.ggj18_theme:stop()
    Music.ggj18_ambient:play()
  elseif n==2 then
    map = sti("map/level1.lua", { "box2d" })
    -- Music.theme:play()
  elseif n==3 then
    map = sti("map/level2.lua", { "box2d" })
    -- Music.theme:play()
  elseif n==4 then
    map = sti("map/level3.lua", { "box2d" })
    -- Music.theme:play()
  elseif n==5 then
    map = sti("map/level4.lua", { "box2d" })
    -- Music.theme:play()
  end
    
  if map ~= nil then
    -- Prepare physics world
    world = love.physics.newWorld(0, 0)

    -- Prepare collision objects
    map:box2d_init(world)

    sprite_list = {}
    -- Create new dynamic data layer called "Sprites" as the nth layer
    local layerSprites = map:addCustomLayer("Sprites", #map.layers - 1)
    -- Draw player
    layerSprites.draw = function(self)
  
      -- Temporarily draw a point at our location so we know
      -- that our sprite is offset properly
      -- love.graphics.setPointSize(8)
      -- love.graphics.points(math.floor(player.pos.x), math.floor(player.pos.y))
  
      for _,spr in pairs(sprite_list) do
        if spr.active then
          spr.current_animation[spr.current_direction]:draw(spr.sprite,spr.pos.x-spr.pxw/2,spr.pos.y-spr.pxh/1.1)
        end
        if spr.type == 'enemy' then
          if spr.active then
            spr.update(player)
          end        
        end
        
        if debug_mode then
          if spr.body ~= nil then 
            love.graphics.setColor(255,0,0)
            -- love.graphics.polygon("line",spr.body:getWorldPoints(spr.shape:getPoints()))
            local x, y = spr.body:getWorldCenter()
            love.graphics.circle("line", x, y, 4)
          end
          love.graphics.setColor(20, 180, 255)
          love.graphics.circle("line", spr.pos.x, spr.pos.y, 80)
          love.graphics.setColor(255,255,255)
        end
      end
    end

    -- Get exit points of the map
    for k, object in pairs(map.objects) do
      if object.name == "Exit" then
        table.insert(list_exit_points, object)
        break
      end
    end
  
    local spawn_point
    -- Get player spawn object
    for k, object in pairs(map.objects) do
      if object.name == "Player" then
        spawn_point = object
          break
      end
    end

    -- Get triggers object
    for k, object in pairs(map.objects) do
      if object.properties['type'] == "trigger" and object.properties.msg ~= nil then
        table.insert(list_triggers,object)
        -- transmissionMessages[k] = {}
        object.properties.id = tonumber(object.properties.spawnEnnemy )
        transmissionMessages[object.properties.id] = {}
        local aMessages = lume.splitStr(object.properties.msg, "&")
        -- sayInBox(object.properties.msg)
        -- print (object.properties.msg)
        for i = 1, #aMessages do
          -- print(aMessages[i])
          table.insert(transmissionMessages[object.properties.id], { seen = false, msg = aMessages[i] })
        end
        table.insert(transmissionMessages[object.properties.id], { seen = false, msg = "" })
        -- print("\n")
      end
    end


    -- Get items object
    for k, object in pairs(map.objects) do
      if object.name == "itemSpawner" then
        if object.properties.item == 'radio' then
          local radio = Item.init('radio','img/chara_radio.png',object.x,object.y)
          table.insert(sprite_list,radio)
          object = nil 
          map.objects[k] = nil
        end
      end 
    end


    -- Get triggers object
    for k, object in pairs(map.objects) do
      if object.name == "ennemySpawner" then
        object.properties.id = tonumber(object.properties.id )
        -- table.insert(list_enemySpawner,object)
        local enemy = Character.init('enemy','img/chara_agent.png',object.x,object.y)
        enemy.id = object.properties.id
        enemy.active = false
        enemy.body = love.physics.newBody(world, enemy.pos.x, enemy.pos.y, "dynamic")
        enemy.body:setLinearDamping(10)
        enemy.body:setFixedRotation(true)
        enemy.shape   = love.physics.newCircleShape(enemy.pxw/2, enemy.pxh/2, 6)
        enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape)
        enemy.body:setActive(false)
        enemy.update = function(target)
          if (screen_msg ~= nil and string.len(screen_msg) > 1) then
          else
            local vx, vy = enemy.body:getLinearVelocity()
            local acc = 10
            local dst = lume.distance(enemy.pos.x, enemy.pos.y, target.pos.x, target.pos.y)
            if (dst < 150) then
              if (enemy.pos.x > target.pos.x + 6) then
                vx = vx - acc
              elseif (enemy.pos.x < target.pos.x - 6) then
                vx = vx + acc
              end
    
              if (enemy.pos.y > target.pos.y + 6) then
                vy = vy - acc
              elseif (enemy.pos.x < target.pos.y - 6) then
                vy = vy + acc
              end
              enemy.body:setLinearVelocity(vx, vy)
              enemy.pos.x, enemy.pos.y = enemy.body:getWorldCenter()
    
              if (vx > 10) then
                enemy.current_direction = 'right'
                if vy > 10 then
                  enemy.current_direction = 'down_right'
                elseif vy < -10 then
                  enemy.current_direction = 'up_right'
                end
              elseif (vx < -10) then
                enemy.current_direction = 'left'
                if vy > 10 then
                  enemy.current_direction = 'down_left'
                elseif vy < -10 then
                  enemy.current_direction = 'up_left'
                end
              else
                if vy > 10 then
                  enemy.current_direction = 'down'
                elseif vy < -10 then
                  enemy.current_direction = 'up'
                end
              end
            end
          end
        end
        table.insert(sprite_list,enemy)
      end
    end

    player = Character.init('player','img/chara_player.png',spawn_point.x,spawn_point.y)
    player.body = love.physics.newBody(world, player.pos.x, player.pos.y, "dynamic")
    player.body:setLinearDamping(10)
    player.body:setFixedRotation(true)
    player.shape   = love.physics.newCircleShape(player.pxw/2, player.pxh/2, 6)
    player.fixture = love.physics.newFixture(player.body, player.shape)

    table.insert(sprite_list,player)
  
    player.current_animation = player.animations.walk
  
    camera = Camera(player.pos.x, player.pos.y)
  end

  last_level = n
end


function Game:enter()
  is_accept_enable = true

end

function Game:init()
  img_chara_agent = love.graphics.newImage('img/chara_agent.png')
  local g_chara_agent = anim8.newGrid(24, 24, img_chara_agent:getWidth(), img_chara_agent:getHeight())

  cnv = love.graphics.newCanvas(GAME_WIDTH,GAME_HEIGHT)

  setLevel(1)
end


function Game:update(dt)
  -- Make sure to do this or nothign will work!
  -- updates Timer, pay attention to use dot instead of collon
  Timer.update(dt)

  -- waitForButton
  WaitForButton:update(dt)
  
  -- update the world
  world:update(dt)

  local speed = 96
  

  if keys_pressed['up'] and keys_pressed['right'] then 
    player.current_direction = 'up_right'
  elseif  keys_pressed['up'] and keys_pressed['left'] then 
    player.current_direction = 'up_left'
  elseif  keys_pressed['down'] and keys_pressed['right'] then 
    player.current_direction = 'down_right'
  elseif  keys_pressed['down'] and keys_pressed['left'] then 
    player.current_direction = 'down_left'
  elseif  keys_pressed['up'] then 
    player.current_direction = 'up'
  elseif  keys_pressed['left'] then 
    player.current_direction = 'left'
  elseif  keys_pressed['right'] then 
    player.current_direction = 'right'
  elseif  keys_pressed['down'] then 
    player.current_direction = 'down'
  end

  
  local force_x, force_y = 0, 0
  local vx, vy = player.body:getLinearVelocity()
  local acc = 44
  
  if keys_pressed['up'] or keys_pressed['down'] then
    if keys_pressed['up']then
      if player.pos.y > 0 then
        -- player.pos.y=player.pos.y-speed*dt
        -- force_y = force_y - 400
        vy = vy - acc
      end
    end

    if keys_pressed['down'] then
      if player.pos.y < map.height*map.tileheight then
        -- player.pos.y=player.pos.y+speed*dt
        -- force_y = force_y + 400
        vy = vy + acc
      end
    end
  else
    vy = lume.lerp(vy, 0, 0.2)
  end

  if keys_pressed['left'] or keys_pressed['right'] then
    if keys_pressed['left'] then
      if player.pos.x > 0 then
        -- player.pos.x=player.pos.x-speed*dt
        -- force_x = force_x - 400
        vx = vx - acc
      end
    end

    if keys_pressed['right'] then
      if player.pos.x < map.width*map.tilewidth then
        -- player.pos.x=player.pos.x+speed*dt
        -- force_x = force_x + 400
        vx = vx + acc
      end
    end
  else
    vx = lume.lerp(vx, 0, 0.2)
  end

  if (screen_msg ~= nil and string.len(screen_msg) > 1) then
    vx = 0
    vy = 0
  else
    vx = lume.clamp(vx, -140, 140)
    vy = lume.clamp(vy, -140, 140)
  end

  player.body:setLinearVelocity(vx, vy);

	-- player.body:applyForce(force_x, force_y)
  player.pos.x, player.pos.y = player.body:getWorldCenter()
  player.pos.y = player.pos.y + 2

  local dx = player.pos.x - camera.x
  local dy = player.pos.y - camera.y

  for _,spr in pairs(sprite_list) do
    spr.current_animation[spr.current_direction]:update(dt)
  end

  map:update(dt)
  camera:move(dx/2, dy/2)


  -- lets check collision with items
  for k, object in pairs(sprite_list) do
    if object ~= nil and object.type == 'radio' then

      if object.pos.x >= player.pos.x - player.pxw/2 and
        object.pos.x <= player.pos.x + player.pxw/2 and 
        object.pos.y >= player.pos.y - player.pxh/2 and
        object.pos.y <= player.pos.y + player.pxh/2 then

        -- hack, we need to have a property to tell the proper level to advance to
        object = nil
        sprite_list[k] = nil

        goToGameState('Cutscene')

      end 
    end 
  end


  --     this function checks for all exit points and go to 
  -- next level then when player is on top
  for k, object in pairs(list_exit_points) do
    if object ~= nil then

      if object.x >= player.pos.x - player.pxw/2 and
        object.x <= player.pos.x + player.pxw/2 and 
        object.y >= player.pos.y - player.pxh/2 and
        object.y <= player.pos.y + player.pxh/2 then

        -- hack, we need to have a property to tell the proper level to advance to
        setLevel(last_level+1)

      end 
    end 
  end

  if currentTransmissionId ~= nil then
    local i = 1
    local t = transmissionMessages[currentTransmissionId]
    
    if t ~= nil then
      for i = 1, #t do
        if i == #t then
          local playCutscene = false
          for j,ent in pairs(sprite_list) do
            if ent.type == 'enemy' and ent.id == currentTransmissionId then
              playCutscene = not ent.active
              --print (currentTransmissionId .. " " .. ent.id)
              ent.active = true
              ent.body:setActive(true)
            end
            if playCutscene then 

              --goToGameState('Cutscene')
            end
          end
          -- break
        end
        if not t[i].seen and f_isAcceptPressed() then
          t[i].seen = true
        end
        if not t[i].seen then
          sayInBox(t[i].msg)
          break
        end
      end
    end
  end

  -- this function checks for all triggers and triger then when player is on top
  for k, object in pairs(list_triggers) do
    if object ~= nil then

      if object.x + object.width >= player.pos.x - player.pxw / 2 and
          object.x <= player.pos.x + player.pxw / 2 and 
          object.y >= player.pos.y - player.pxh / 2 and
          object.y-object.height <= player.pos.y + player.pxh / 2 then
        
        currentTransmissionId = tonumber(object.properties.id)
      -- print('test')
        break
      end
    end

  end

  if restart == true then
    restart = false
    setLevel(1)
  end

end

local ui_texto_y = -600
local function drawFn()
  -- <Your drawing logic goes here.>
  -- love.graphics.draw(padLeft,a,2)
  love.graphics.setShader()
  cnv:renderTo(function()
    love.graphics.clear(0,0,0,255)


    local tx = camera.x - GAME_WIDTH / 2
    local ty = camera.y - GAME_HEIGHT / 2

    if tx < 0 then 
        tx = 0 
    end
    if ty < 0 then 
        ty = 0 
    end
    if tx > map.width  * map.tilewidth  - GAME_WIDTH  then
        tx = map.width  * map.tilewidth  - GAME_WIDTH 
    end
    if ty > map.height * map.tileheight - GAME_HEIGHT then
        ty = map.height * map.tileheight - GAME_HEIGHT
    end

    tx = math.floor(tx)
    ty = math.floor(ty)

    -- print("tx = " , tostring(tx) , "; ty = " , tostring(ty))


    map:draw(-tx, -ty, camera.scale, camera.scale)
    if debug_mode then
      map:box2d_draw(-tx, -ty, camera.scale, camera.scale)
    end

    camera:draw(function()
        
    end)
    -- mapa

    if screen_msg ~= nil and string.len(screen_msg)>1 then
      local t_limit = screen_msg_w-2
      local t_align = 'left'
      love.graphics.setColor( 255, 255, 255, 255 )
      ui_texto_y = lume.lerp(ui_texto_y, 0, .18)
      love.graphics.draw(Image.ui_texto,0,ui_texto_y)
      love.graphics.setColor(0,0,0,128)

      -- love.graphics.rectangle('fill',screen_msg_x,screen_msg_y,screen_msg_w,screen_msg_h, 4,4,6)
      love.graphics.setFont(font_Verdana2)
      love.graphics.setColor( 255, 255, 255, 255 )
      love.graphics.printf(screen_msg,screen_msg_txt_x,screen_msg_txt_y+ui_texto_y, t_limit, t_align)
    else
      --currentTransmissionId = nil
      ui_texto_y = lume.lerp(ui_texto_y, -600, .2)
      love.graphics.draw(Image.ui_texto,0,ui_texto_y)
    end

    -- zuera
    if debug_mode then
      love.graphics.setColor( 255, 255, 255, 255 )
      love.graphics.setFont(font_Verdana2)
      love.graphics.print("DEBUG MODE",32,32)
      love.graphics.print("player x="..player.pos.x..", y="..player.pos.y,32,8)
    end
    
    -- love.graphics.print("O Papagaio come milho.\nperiquito leva a fama.\nCantam uns e choram outros\nTriste sina de quem ama.", 80+20*b, 25)
    -- love.graphics.rectangle("fill", 30+12*b, 30+15*b, 16, 32 )
  end)


  love.graphics.setShader(shader_screen)
  strength = math.sin(love.timer.getTime()*2)
  shader_screen:send("abberationVector", {
    lume.clamp(strength * math.sin(love.timer.getTime() * 3) / 200, 0, 100), 
    lume.clamp(strength * math.sin(love.timer.getTime() * 5) / 200, 0, 100)
  })

  love.graphics.draw(cnv,0,0)
  
end

function Game:draw()


  screen:draw(drawFn) -- Additional arguments will be passed to drawFn.


end

return Game