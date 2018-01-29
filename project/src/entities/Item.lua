local Item = {}
local anim8         = requireLibrary("anim8")

function Item.init(type,image,x,y)
    local anim_time = 0.3
    local chara = {}
    chara.type = type
    chara.pos = { x = x, y = y }
    chara.active = true
    chara.pxw = 24
    chara.pxh = 24
    chara.sprite = love.graphics.newImage(image)
    chara.anim_grid = anim8.newGrid(24, 24, chara.sprite:getWidth(), chara.sprite:getHeight())
    chara.current_direction = 'down'
    chara.animations= { 
      walk = {
        down = anim8.newAnimation(chara.anim_grid('1-4',1), anim_time),
        down_right = anim8.newAnimation(chara.anim_grid('1-4',2), anim_time),
        right = anim8.newAnimation(chara.anim_grid('1-4',3), anim_time),
        up_right = anim8.newAnimation(chara.anim_grid('1-4',4), anim_time),
        up = anim8.newAnimation(chara.anim_grid('1-4',5), anim_time),
        up_left = anim8.newAnimation(chara.anim_grid('1-4',6), anim_time),
        left = anim8.newAnimation(chara.anim_grid('1-4',7), anim_time),
        down_left = anim8.newAnimation(chara.anim_grid('1-4',8), anim_time)
      },
      idle = {
        down = anim8.newAnimation(chara.anim_grid('1-4',1), anim_time),
        down_right = anim8.newAnimation(chara.anim_grid('1-4',2), anim_time),
        right = anim8.newAnimation(chara.anim_grid('1-4',3), anim_time),
        up_right = anim8.newAnimation(chara.anim_grid('1-4',4), anim_time),
        up = anim8.newAnimation(chara.anim_grid('1-4',5), anim_time),
        up_left = anim8.newAnimation(chara.anim_grid('1-4',6), anim_time),
        left = anim8.newAnimation(chara.anim_grid('1-4',7), anim_time),
        down_left = anim8.newAnimation(chara.anim_grid('1-4',8), anim_time)
      }
    }
    chara.current_animation = chara.animations.walk

    return chara
end

return Item