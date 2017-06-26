----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateRichProcessBarUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.des = self.transform:FindChild("@des").gameObject;
		self.slider = self.transform:FindChild("@slider").gameObject;
		self.bg = self.transform:FindChild("@slider/@bg").gameObject;
		self.fg = self.transform:FindChild("@slider/@fg").gameObject;
		self.point = self.transform:FindChild("@slider/@point").gameObject;
	end
	return self;
end
RichProcessBarUI = RichProcessBarUI or CreateRichProcessBarUI();
