----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTaskUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.title = self.transform:FindChild("mask/@title").gameObject;
		self.close = self.transform:FindChild("mask/@close").gameObject;
		self.chapterName = self.transform:FindChild("mask/bgbook/leftpanel/@chapterName").gameObject;
		self.chapterIndex = self.transform:FindChild("mask/bgbook/leftpanel/@chapterIndex").gameObject;
		self.taskList = self.transform:FindChild("mask/bgbook/leftpanel/@taskList").gameObject;
		self.taskItemTemplate = self.transform:FindChild("mask/bgbook/leftpanel/@taskList/Viewport/Content/@taskItemTemplate").gameObject;
		self.bottombar = self.transform:FindChild("mask/bgbook/leftpanel/@bottombar").gameObject;
		self.imgHideFinTask = self.transform:FindChild("mask/bgbook/leftpanel/@bottombar/@imgHideFinTask").gameObject;
		self.imgCheckHide = self.transform:FindChild("mask/bgbook/leftpanel/@bottombar/@imgCheckHide").gameObject;
		self.txtHideFinTask = self.transform:FindChild("mask/bgbook/leftpanel/@bottombar/@txtHideFinTask").gameObject;
		self.txtSectionName = self.transform:FindChild("mask/bgbook/rightpanel/@txtSectionName").gameObject;
		self.btnAbort = self.transform:FindChild("mask/bgbook/rightpanel/@btnAbort").gameObject;
		self.txtAbort = self.transform:FindChild("mask/bgbook/rightpanel/@btnAbort/@txtAbort").gameObject;
		self.btnEnter = self.transform:FindChild("mask/bgbook/rightpanel/@btnEnter").gameObject;
		self.txtEnter = self.transform:FindChild("mask/bgbook/rightpanel/@btnEnter/@txtEnter").gameObject;
		self.txtTaskDesc = self.transform:FindChild("mask/bgbook/rightpanel/descgroup/sv/Viewport/@txtTaskDesc").gameObject;
		self.targetItemTemplate = self.transform:FindChild("mask/bgbook/rightpanel/targetgroup/sv/Viewport/Content/@targetItemTemplate").gameObject;
		self.txtTargetDesc = self.transform:FindChild("mask/bgbook/rightpanel/targetgroup/sv/Viewport/@txtTargetDesc").gameObject;
		self.rewardItemTemplate = self.transform:FindChild("mask/bgbook/rightpanel/rewardgroup/rewardList/Viewport/Content/@rewardItemTemplate").gameObject;
		self.textStory = self.transform:FindChild("mask/bgpage1/@textStory").gameObject;
		self.textAccom = self.transform:FindChild("mask/bgpage2/@textAccom").gameObject;
		self.btnHelp = self.transform:FindChild("mask/@btnHelp").gameObject;
	end
	return self;
end
TaskUI = TaskUI or CreateTaskUI();
