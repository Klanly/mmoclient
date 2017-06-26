----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateIndependentBtnUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.bg = self.transform:FindChild("@bg").gameObject;
		self.btnCheck = self.transform:FindChild("@btnCheck").gameObject;
	end
	return self;
end
IndependentBtnUI = IndependentBtnUI or CreateIndependentBtnUI();
