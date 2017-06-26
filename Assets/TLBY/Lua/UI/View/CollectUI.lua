----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCollectUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.mask = self.transform:FindChild("@mask").gameObject;
		self.bgblue = self.transform:FindChild("@bgblue").gameObject;
	end
	return self;
end
CollectUI = CollectUI or CreateCollectUI();
