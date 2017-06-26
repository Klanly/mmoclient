--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/11 0011
-- Time: 19:55
-- To change this template use File | Settings | File Templates.
--
require "UI/View/LuaViewBase"

local function CreatePromptUI()
	local self = CreateViewBase()
	self.Awake = function()
        self.Msg = self.transform:FindChild("Msg").gameObject
        self.Bg = self.transform:FindChild("Bg").gameObject
	end
	return self
end
PromptUI = PromptUI or CreatePromptUI()

