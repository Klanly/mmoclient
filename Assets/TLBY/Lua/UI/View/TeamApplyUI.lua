----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTeamApplyUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.title = self.transform:FindChild("@title").gameObject;
		self.tab = self.transform:FindChild("pageLeft/@tab").gameObject;
		self.tabList = self.transform:FindChild("pageLeft/tabScrollView/Viewport/@tabList").gameObject;
		self.subBtns = self.transform:FindChild("pageLeft/tabScrollView/Viewport/@tabList/@subBtns").gameObject;
		self.subBtn = self.transform:FindChild("pageLeft/tabScrollView/Viewport/@tabList/@subBtns/@subBtn").gameObject;
		self.scrollView = self.transform:FindChild("teamList/@scrollView").gameObject;
		self.teamItem = self.transform:FindChild("teamList/@teamItem").gameObject;
		self.noTeam = self.transform:FindChild("@noTeam").gameObject;
		self.btnAutoApply = self.transform:FindChild("@btnAutoApply").gameObject;
		self.btnCreate = self.transform:FindChild("@btnCreate").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
	end
	return self;
end
TeamApplyUI = TeamApplyUI or CreateTeamApplyUI();
