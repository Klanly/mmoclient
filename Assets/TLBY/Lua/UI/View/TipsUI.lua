----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTipsUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("bg/@btnClose").gameObject;
		self.des = self.transform:FindChild("bg/Scrollview/Viewport/@des").gameObject;
	end
	return self;
end
TipsUI = TipsUI or CreateTipsUI();
