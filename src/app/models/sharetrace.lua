
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local sharetrace = class("sharetrace")
local luajAppActivity = "org/cocos2dx/lua/AppActivity"

function sharetrace:getInstallTrace(seconds, callback)
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local luaj = require "cocos.cocos2d.luaj"
		local args = {seconds, callback}
		local signs = "(II)V"
		local ok, ret = luaj.callStaticMethod(luajAppActivity, "getInstallTrace", args, signs)
		if not ok then
			print("luaj call getInstallTrace error: "..ret)
		end
	end
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
        local luaoc = require "cocos.cocos2d.luaoc"
        local args = {funcId = callback, seconds = seconds}
        local ok, ret = luaoc.callStaticMethod("SharetraceBridge", "getInstallTrace", args)
        if not ok then
            print("luaoc getInstallTrace error: "..ret)
        end
    end
end


function sharetrace:registerWakeUpTrace(callback)
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local luaj = require "cocos.cocos2d.luaj"
		local args = {callback}
		local signs = "(I)V"
		local ok, ret = luaj.callStaticMethod(luajAppActivity, "registerWakeUpTrace", args, signs)
		if not ok then
			print("luaj call registerWakeUpTrace error: "..ret)
		end
	end
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
        local luaoc = require "cocos.cocos2d.luaoc"
        local args = {funcId = callback}
        local ok, ret = luaoc.callStaticMethod("SharetraceBridge", "registerWakeUpTrace", args)
        if not ok then
            print("luaoc registerWakeUpTrace error: "..ret)
        end
    end
end

return sharetrace
