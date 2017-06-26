----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePlayerOpUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.bg = self.transform:FindChild("@bg").gameObject;
		self.position = self.transform:FindChild("@position").gameObject;
		self.icon = self.transform:FindChild("@position/bgOtherparty/bgmessagebox/mask/@icon").gameObject;
		self.name = self.transform:FindChild("@position/bgOtherparty/bgmessagebox/@name").gameObject;
		self.textRanks = self.transform:FindChild("@position/bgOtherparty/bgmessagebox/@textRanks").gameObject;
		self.teamInfo = self.transform:FindChild("@position/@teamInfo").gameObject;
		self.check = self.transform:FindChild("@position/btns/@check").gameObject;
		self.btnCheck = self.transform:FindChild("@position/btns/@check/@btnCheck").gameObject;
		self.teamApply = self.transform:FindChild("@position/btns/@teamApply").gameObject;
		self.btnTeamApply = self.transform:FindChild("@position/btns/@teamApply/@btnTeamApply").gameObject;
		self.teamInvite = self.transform:FindChild("@position/btns/@teamInvite").gameObject;
		self.btnTeamInvite = self.transform:FindChild("@position/btns/@teamInvite/@btnTeamInvite").gameObject;
		self.addFriend = self.transform:FindChild("@position/btns/@addFriend").gameObject;
		self.btnAddFriend = self.transform:FindChild("@position/btns/@addFriend/@btnAddFriend").gameObject;
		self.removeFriend = self.transform:FindChild("@position/btns/@removeFriend").gameObject;
		self.btnRemoveFriend = self.transform:FindChild("@position/btns/@removeFriend/@btnRemoveFriend").gameObject;
		self.factionInvite = self.transform:FindChild("@position/btns/@factionInvite").gameObject;
		self.btnFactionInvite = self.transform:FindChild("@position/btns/@factionInvite/@btnFactionInvite").gameObject;
		self.addBlackList = self.transform:FindChild("@position/btns/@addBlackList").gameObject;
		self.btnAddBlackList = self.transform:FindChild("@position/btns/@addBlackList/@btnAddBlackList").gameObject;
		self.removeBlackList = self.transform:FindChild("@position/btns/@removeBlackList").gameObject;
		self.btnRemoveBlackList = self.transform:FindChild("@position/btns/@removeBlackList/@btnRemoveBlackList").gameObject;
		self.addEnemy = self.transform:FindChild("@position/btns/@addEnemy").gameObject;
		self.btnAddEnemy = self.transform:FindChild("@position/btns/@addEnemy/@btnAddEnemy").gameObject;
		self.removeEnemy = self.transform:FindChild("@position/btns/@removeEnemy").gameObject;
		self.btnRemoveEnemy = self.transform:FindChild("@position/btns/@removeEnemy/@btnRemoveEnemy").gameObject;
		self.giftGiving = self.transform:FindChild("@position/btns/@giftGiving").gameObject;
		self.btnGiftGiving = self.transform:FindChild("@position/btns/@giftGiving/@btnGiftGiving").gameObject;
		self.factionPosition = self.transform:FindChild("@position/btns/@factionPosition").gameObject;
		self.btnFactionPosition = self.transform:FindChild("@position/btns/@factionPosition/@btnFactionPosition").gameObject;
		self.kickFaction = self.transform:FindChild("@position/btns/@kickFaction").gameObject;
		self.btnKickFaction = self.transform:FindChild("@position/btns/@kickFaction/@btnKickFaction").gameObject;
		self.transferChief = self.transform:FindChild("@position/btns/@transferChief").gameObject;
		self.btnTransferChief = self.transform:FindChild("@position/btns/@transferChief/@btnTransferChief").gameObject;
	end
	return self;
end
PlayerOpUI = PlayerOpUI or CreatePlayerOpUI();
