----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePlayerResourceUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.layoutGroup = self.transform:FindChild("@layoutGroup").gameObject;
		self.item = self.transform:FindChild("@layoutGroup/@item").gameObject;
	end
	return self;
end
PlayerResourceUI = PlayerResourceUI or CreatePlayerResourceUI();
