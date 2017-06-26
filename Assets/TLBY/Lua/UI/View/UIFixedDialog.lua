----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateUIFixedDialog()
	local self = CreateViewBase();
	self.Awake = function()
		self.text = self.transform:FindChild("@text").gameObject;
	end
	return self;
end
UIFixedDialog = UIFixedDialog or CreateUIFixedDialog();
