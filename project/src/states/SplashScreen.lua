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

SplashScreen = Gamestate.new()

local stuff = {}
local opacityTween
local opacity_step
local opacity_step_out
local opacityTweenFadout
local change_scene_once
local cutscene_active 

local only_once
local function doOnlyOnce(fn)
  if only_once ~= true then
    only_once = true
    fn()
  end
end

local is_accept_enable = false
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


function SplashScreen:enter()
  only_once = false
  is_accept_enable = false
  cutscene_active = true
  opacityTween = 0
  opacity_step = 4
  opacity_step_out = 6
  change_scene_once = true
  opacityTweenFadout = 255
  Sfx.Vaca_Load:play()
end

function SplashScreen:update(dt)
  Timer.update(dt)

  if f_isAcceptPressed() then 
    print('pressed')
    goToGameState('StartScreen')
  end


  if opacityTween<256-opacity_step then
    opacityTween = opacityTween + opacity_step
  else 
    doOnlyOnce(function()
      is_accept_enable = true
    end)

    if opacityTweenFadout>0+opacity_step_out then
      opacityTweenFadout = opacityTweenFadout - opacity_step_out
    else 
      goToGameState('StartScreen')
    end
    
  end

end


local function drawFn2()
    -- <Your drawing logic goes here.>
    -- love.graphics.draw(padLeft,a,2)
    love.graphics.setShader()
    cnv = love.graphics.newCanvas(GAME_WIDTH,GAME_HEIGHT)
    cnv:renderTo(function()
      if opacityTween < 256-opacity_step then
        love.graphics.setColor(255,255,255,opacityTween)
      else
        love.graphics.setColor(255,255,255,opacityTweenFadout)
      end

      love.graphics.draw(Image.vaca_splash)
    end)


    love.graphics.setShader(shader_screen)
    love.graphics.draw(cnv,0,0)
    strength = 2*math.sin(love.timer.getTime()*3)
    shader_screen:send("abberationVector", {strength*math.sin(love.timer.getTime()*7)/150, strength*math.cos(love.timer.getTime()*7)/200})

    
end

function SplashScreen:draw()
    screen:draw(drawFn2) -- Additional arguments will be passed to drawFn
end

return SplashScreen