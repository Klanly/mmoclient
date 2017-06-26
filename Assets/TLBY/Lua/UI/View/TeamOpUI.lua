----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTeamOpUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.rect = self.transform:FindChild("@rect").gameObject;
		self.bg = self.transform:FindChild("@bg").gameObject;
		self.btnSendMsg = self.transform:FindChild("@bg/@btnSendMsg").gameObject;
		self.btnCheckInfo = self.transform:FindChild("@bg/@btnCheckInfo").gameObject;
		self.btnAddFriend = self.transform:FindChild("@bg/@btnAddFriend").gameObject;
		self.btnCaptain = self.transform:FindChild("@bg/@btnCaptain").gameObject;
		self.btnKickTeam = self.transform:FindChild("@bg/@btnKickTeam").gameObject;
		self.btnSummon = self.transform:FindChild("@bg/@btnSummon").gameObject;
		self.btnMoveTo = self.transform:FindChild("@bg/@btnMoveTo").gameObject;
		self.btnLeaveTeam = self.transform:FindChild("@bg/@btnLeaveTeam").gameObject;
	end
	return self;
end
TeamOpUI = TeamOpUI or CreateTeamOpUI();
