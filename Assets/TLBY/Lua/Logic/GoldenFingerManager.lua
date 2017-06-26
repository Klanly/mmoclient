--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/10 0010
-- Time: 14:01
-- To change this template use File | Settings | File Templates.
--

require "Common/basic/LuaObject"

local function CreateGoldenFingerManager()
    local self = CreateObject()

    -- 无CD模式
    self.NoCDMode = false

    local function OnReceiveGoldenFingerResult(data)
        if not data.result then return end
        print("golden result:"..data.result)
        if string.sub(data.result, 0, 3) == '-cd' then
        	self.NoCDMode = true
        end
    end

    self.Init = function()
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GM, OnReceiveGoldenFingerResult)
    end

    self.Init()

    return self
end

GoldenFingerManager = GoldenFingerManager or CreateGoldenFingerManager()

