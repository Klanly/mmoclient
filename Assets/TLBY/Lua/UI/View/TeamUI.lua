----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTeamUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.player1 = self.transform:FindChild("teamMember/@player1").gameObject;
		self.player2 = self.transform:FindChild("teamMember/@player2").gameObject;
		self.player3 = self.transform:FindChild("teamMember/@player3").gameObject;
		self.player4 = self.transform:FindChild("teamMember/@player4").gameObject;
		self.btnadd1 = self.transform:FindChild("teamMember/@btnadd1").gameObject;
		self.btnadd2 = self.transform:FindChild("teamMember/@btnadd2").gameObject;
		self.btnadd3 = self.transform:FindChild("teamMember/@btnadd3").gameObject;
		self.btnadd4 = self.transform:FindChild("teamMember/@btnadd4").gameObject;
		self.autoAgreeToggle = self.transform:FindChild("agreeLabel/@autoAgreeToggle").gameObject;
		self.targetLabel = self.transform:FindChild("@targetLabel").gameObject;
		self.targetDes = self.transform:FindChild("@targetLabel/@targetDes").gameObject;
		self.btnLeave = self.transform:FindChild("btns/@btnLeave").gameObject;
		self.btnCancelSummon = self.transform:FindChild("btns/@btnCancelSummon").gameObject;
		self.btnSummon = self.transform:FindChild("btns/@btnSummon").gameObject;
		self.btnFollow = self.transform:FindChild("btns/@btnFollow").gameObject;
		self.btnCancelFollow = self.transform:FindChild("btns/@btnCancelFollow").gameObject;
		self.btnEnter = self.transform:FindChild("btns/@btnEnter").gameObject;
		self.btnRecruitFriends = self.transform:FindChild("btns/@btnRecruitFriends").gameObject;
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.btnQuest = self.transform:FindChild("@btnQuest").gameObject;
	end
	return self;
end
TeamUI = TeamUI or CreateTeamUI();
