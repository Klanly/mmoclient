----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTeamDungeonUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.icon = self.transform:FindChild("mask/@icon").gameObject;
		self.btnTeam = self.transform:FindChild("btns/@btnTeam").gameObject;
		self.btnTeamMember = self.transform:FindChild("btns/@btnTeamMember").gameObject;
		self.btnEnter = self.transform:FindChild("btns/@btnEnter").gameObject;
		self.dungeonList = self.transform:FindChild("@dungeonList").gameObject;
		self.dungeonTypeItem = self.transform:FindChild("@dungeonList/Viewport/content/@dungeonTypeItem").gameObject;
		self.diffList = self.transform:FindChild("@diffList").gameObject;
		self.diffItem = self.transform:FindChild("@diffList/Viewport/content/@diffItem").gameObject;
		self.dropItemList = self.transform:FindChild("@dropItemList").gameObject;
		self.dropItem = self.transform:FindChild("@dropItemList/Viewport/content/@dropItem").gameObject;
		self.leftTime = self.transform:FindChild("title/@leftTime").gameObject;
		self.bestPlayer = self.transform:FindChild("title/@bestPlayer").gameObject;
		self.dungonDes = self.transform:FindChild("title/ScrollView/Viewport/@dungonDes").gameObject;
	end
	return self;
end
TeamDungeonUI = TeamDungeonUI or CreateTeamDungeonUI();
