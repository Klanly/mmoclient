----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTeamChangeTargetUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.btnDetermine = self.transform:FindChild("@btnDetermine").gameObject;
		self.levelLeftScrollView = self.transform:FindChild("@levelLeftScrollView").gameObject;
		self.levelItem = self.transform:FindChild("@levelLeftScrollView/Viewport/content/@levelItem").gameObject;
		self.levelRightScrollView = self.transform:FindChild("@levelRightScrollView").gameObject;
		self.tabList = self.transform:FindChild("tabScrollView/Viewport/@tabList").gameObject;
		self.tab = self.transform:FindChild("tabScrollView/Viewport/@tabList/@tab").gameObject;
		self.subBtns = self.transform:FindChild("tabScrollView/Viewport/@tabList/@subBtns").gameObject;
		self.subBtn = self.transform:FindChild("tabScrollView/Viewport/@tabList/@subBtns/@subBtn").gameObject;
	end
	return self;
end
TeamChangeTargetUI = TeamChangeTargetUI or CreateTeamChangeTargetUI();
