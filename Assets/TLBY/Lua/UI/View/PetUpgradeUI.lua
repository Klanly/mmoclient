----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePetUpgradeUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.bg = self.transform:FindChild("@bg").gameObject;
		self.grid = self.transform:FindChild("bgdebris/@grid").gameObject;
		self.item = self.transform:FindChild("bgdebris/@grid/@item").gameObject;
	end
	return self;
end
PetUpgradeUI = PetUpgradeUI or CreatePetUpgradeUI();
