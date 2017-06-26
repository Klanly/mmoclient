----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateFactionPositionUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.grid = self.transform:FindChild("@grid").gameObject;
		self.item = self.transform:FindChild("@grid/@item").gameObject;
	end
	return self;
end
FactionPositionUI = FactionPositionUI or CreateFactionPositionUI();
