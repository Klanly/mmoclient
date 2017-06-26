----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateProcessBarUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.des = self.transform:FindChild("@des").gameObject;
		self.slider = self.transform:FindChild("@slider").gameObject;
	end
	return self;
end
ProcessBarUI = ProcessBarUI or CreateProcessBarUI();
