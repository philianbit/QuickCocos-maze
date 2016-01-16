
require("config")
require("cocos.init")
require("framework.init")
require("app.layers.BackgroundLayer")
require("app.actor.Player")

local MyApp = class("MyApp", cc.mvc.AppBase)



function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    cc.Director:getInstance():setContentScaleFactor(640/CONFIG_SCREEN_HEIGHT)
    --默认从第一关开始
    -- cc.UserDefault:getInstance():setIntegerForKey("passLevel", 0)
    -- cc.UserDefault:getInstance():setIntegerForKey("bestTime", 600)
    cc.UserDefault:getInstance():setBoolForKey("soundOn", true)

    audio.preloadSound("sound/print.wav")
    audio.preloadSound("sound/heavyprint.wav")
    audio.preloadMusic("sound/bk.mp3")
    self:enterScene("MainScene")
end

return MyApp
