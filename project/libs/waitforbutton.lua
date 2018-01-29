
local WaitForButton = {}

function WaitForButton:update(dt)
  if WaitForButton.updater ~= nil then
    WaitForButton.updater()
    return
  end
end


function WaitForButton:init(checkbtnfunction,callback)
  --print(callback)
  --print(checkbtnfunction)
  WaitForButton = {

    checkf = checkbtnfunction,
    callback = callback,
    updater = function (dt)
        --print('is updater')
        if WaitForButton.checkf ~= nil and WaitForButton.callback ~= nil then
          if WaitForButton.checkf() then
            WaitForButton.callback()
          end
        end
    end,
  }
  
end

return WaitForButton