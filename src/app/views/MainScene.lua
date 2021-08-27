
local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local sharetrace = require("app.models.sharetrace")

function MainScene:onCreate()
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)
    
    local function onInstallResult(result)
        print("onInstallResult:"..result)
    end

    local function onWakeupResult(result)
        print("onWakeupResult:"..result)
    end

    sharetrace:getInstallTrace(10, onInstallResult)

    sharetrace:registerWakeUpTrace(onWakeupResult)

end

return MainScene
