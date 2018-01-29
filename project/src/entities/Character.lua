local Character = {}
local anim8         = requireLibrary("anim8")

function Character.init(type,image,x,y)
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
        down = anim8.newAnimation(chara.anim_grid('1-4',1), 0.1),
        down_right = anim8.newAnimation(chara.anim_grid('1-4',2), 0.1),
        right = anim8.newAnimation(chara.anim_grid('1-4',3), 0.1),
        up_right = anim8.newAnimation(chara.anim_grid('1-4',4), 0.1),
        up = anim8.newAnimation(chara.anim_grid('1-4',5), 0.1),
        up_left = anim8.newAnimation(chara.anim_grid('1-4',6), 0.1),
        left = anim8.newAnimation(chara.anim_grid('1-4',7), 0.1),
        down_left = anim8.newAnimation(chara.anim_grid('1-4',8), 0.1)
      },
      idle = {
        down = anim8.newAnimation(chara.anim_grid(2,1), 0.1),
        down_right = anim8.newAnimation(chara.anim_grid(2,2), 0.1),
        right = anim8.newAnimation(chara.anim_grid(2,3), 0.1),
        up_right = anim8.newAnimation(chara.anim_grid(2,4), 0.1),
        up = anim8.newAnimation(chara.anim_grid(2,5), 0.1),
        up_left = anim8.newAnimation(chara.anim_grid(2,6), 0.1),
        left = anim8.newAnimation(chara.anim_grid(2,7), 0.1),
        down_left = anim8.newAnimation(chara.anim_grid(2,8), 0.1)
      }
    }
    chara.current_animation = chara.animations.walk

    return chara
end

return Character