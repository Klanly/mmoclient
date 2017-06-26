----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePropertyChangeUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.tips2 = self.transform:FindChild("@tips2").gameObject;
		self.mask = self.transform:FindChild("@tips2/@mask").gameObject;
		self.bgtips2 = self.transform:FindChild("@tips2/@bgtips2").gameObject;
		self.ScrollView = self.transform:FindChild("@tips2/@ScrollView").gameObject;
		self.Content = self.transform:FindChild("@tips2/@ScrollView/Viewport/@Content").gameObject;
	end
	return self;
end
PropertyChangeUI = PropertyChangeUI or CreatePropertyChangeUI();
