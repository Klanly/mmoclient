----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCampBattleStatusUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.Fightingui = self.transform:FindChild("@Fightingui").gameObject;
		self.btnClose = self.transform:FindChild("@Fightingui/@btnClose").gameObject;
		self.scrollView = self.transform:FindChild("@Fightingui/@scrollView").gameObject;
		self.logItem = self.transform:FindChild("@Fightingui/@scrollView/Viewport/content/@logItem").gameObject;
	end
	return self;
end
CampBattleStatusUI = CampBattleStatusUI or CreateCampBattleStatusUI();
