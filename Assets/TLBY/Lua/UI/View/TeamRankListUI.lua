----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTeamRankListUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("main/@btnClose").gameObject;
		self.dungeonName = self.transform:FindChild("main/@dungeonName").gameObject;
		self.rank1 = self.transform:FindChild("main/@rank1").gameObject;
		self.rank2 = self.transform:FindChild("main/@rank2").gameObject;
		self.rank3 = self.transform:FindChild("main/@rank3").gameObject;
		self.btnConfirm = self.transform:FindChild("main/@btnConfirm").gameObject;
	end
	return self;
end
TeamRankListUI = TeamRankListUI or CreateTeamRankListUI();
