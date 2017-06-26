----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCommTextTipUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.Bottom = self.transform:FindChild("@Bottom").gameObject;
		self.Top = self.transform:FindChild("@Top").gameObject;
		self.Bg = self.transform:FindChild("@Top/@Bg").gameObject;
		self.Content = self.transform:FindChild("@Top/@Content").gameObject;
	end
	return self;
end
CommTextTipUI = CommTextTipUI or CreateCommTextTipUI();
