--
--  Game
--

local Gamestate     = requireLibrary("hump.gamestate")
local Timer         = requireLibrary("hump.timer")
local Vector        = requireLibrary("hump.vector")
local Tween         = Timer.tween
local map
local a
local b
local strength
local cnv

StartScreen = Gamestate.new()

local stuff = {}
local opacityTween
local cutscene_p1_xpos
local cutscene_p2_xpos
local cutscene_p3_xpos
local opacity_step
local xpos_step
local change_scene_once
local cutscene_active 

local selected_credits
local selected_start


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


local is_up_enable = true
local function f_isUpPressed()
  if  is_up_enable and keys_pressed['up'] then 
    is_up_enable = false

   -- print(keys_pressed['buttona'])
    -- prevents player from skipping all text by accident
    Timer.after(0.6, function()
      is_up_enable = true
    end)
    return true
  else
    return false
  end
end

local is_down_enable = true
local function f_isDownPressed()
  if  is_down_enable and keys_pressed['down'] then 
    is_down_enable = false

   -- print(keys_pressed['buttona'])
    -- prevents player from skipping all text by accident
    Timer.after(0.6, function()
      is_down_enable = true
    end)
    return true
  else
    return false
  end
end

function StartScreen:enter()
  cutscene_active = true
  opacityTween = 0
  xpos_step = 8
  opacity_step = 2
  change_scene_once = true
  love.audio.stop()
  Music.ggj18_ambient:stop()
  Music.ggj18_theme:play()
end

function StartScreen:update(dt)
  Timer.update(dt)

  if f_isUpPressed() then
    selected_credits = false
    selected_start = true 

  elseif f_isDownPressed() then 
    selected_credits = true
    selected_start = false 
  
  end

  if f_isAcceptPressed() then 
    if selected_start then
      selected_start = false 
      selected_credits = false 
      goToGameState('Game')
    elseif selected_credits then
      selected_start = false 
      selected_credits = false 
      goToGameState('CreditsState')
    end

  end


  if opacityTween<256-opacity_step then
    opacityTween = opacityTween + opacity_step
  else 

  end

end


local function drawFn2()
    -- <Your drawing logic goes here.>
    -- love.graphics.draw(padLeft,a,2)
    love.graphics.setShader()
    cnv = love.graphics.newCanvas(GAME_WIDTH,GAME_HEIGHT)
    cnv:renderTo(function()
      love.graphics.setColor(255,255,255,opacityTween)
      if opacityTween<256-opacity_step then
        love.graphics.draw(Image.logo)
      else
        love.graphics.draw(Image.menu)

        love.graphics.setFont(font_Verdana2)
        local txt_x = 96
        local txt_y = 64
        local txt_y2 = txt_y+12
        love.graphics.setColor(12,158,100,196)
        love.graphics.print('> Hello, Susan ',txt_x,txt_y-12)
        love.graphics.print(' - Start',txt_x,txt_y)
        love.graphics.print(' - Credits',txt_x,txt_y2)
        
        love.graphics.setColor(255,255,255,128)
        if selected_start then 
          love.graphics.print(' - Start',txt_x,txt_y)

        end

        if selected_credits then 
          love.graphics.print(' - Credits',txt_x,txt_y2)

        end

      end
    end)


    love.graphics.setShader(shader_screen)
    strength = math.sin(love.timer.getTime()*2)
    shader_screen:send("abberationVector", {strength*math.sin(love.timer.getTime()*7)/200, strength*math.cos(love.timer.getTime()*7)/200})

    love.graphics.draw(cnv,0,0)
    
end

function StartScreen:draw()
    screen:draw(drawFn2) -- Additional arguments will be passed to drawFn.
end

return StartScreen