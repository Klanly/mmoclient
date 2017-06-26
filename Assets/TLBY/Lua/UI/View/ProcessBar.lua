----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateProcessBar()
	local self = CreateViewBase();
	self.Awake = function()
	end
	return self;
end
ProcessBar = ProcessBar or CreateProcessBar();
