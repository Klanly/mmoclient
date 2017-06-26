----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTeamInviteUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("Recruitfriendsui/@btnClose").gameObject;
		self.tabFriend = self.transform:FindChild("Recruitfriendsui/@tabFriend").gameObject;
		self.tabNearby = self.transform:FindChild("Recruitfriendsui/@tabNearby").gameObject;
		self.playerItem = self.transform:FindChild("Recruitfriendsui/@playerItem").gameObject;
		self.scrollView = self.transform:FindChild("@scrollView").gameObject;
	end
	return self;
end
TeamInviteUI = TeamInviteUI or CreateTeamInviteUI();
