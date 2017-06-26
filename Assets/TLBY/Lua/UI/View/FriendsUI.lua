----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateFriendsUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnFriend = self.transform:FindChild("tabs/@btnFriend").gameObject;
		self.btnMail = self.transform:FindChild("tabs/@btnMail").gameObject;
		self.mailRedDot = self.transform:FindChild("tabs/@btnMail/@mailRedDot").gameObject;
		self.mailRed = self.transform:FindChild("tabs/@mailRed").gameObject;
		self.unredMailCount = self.transform:FindChild("tabs/@mailRed/@unredMailCount").gameObject;
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.contractItem = self.transform:FindChild("left/@contractItem").gameObject;
		self.tab1 = self.transform:FindChild("left/toggleGroup/@tab1").gameObject;
		self.tabText1 = self.transform:FindChild("left/toggleGroup/@tab1/@tabText1").gameObject;
		self.tab2 = self.transform:FindChild("left/toggleGroup/@tab2").gameObject;
		self.tabText2 = self.transform:FindChild("left/toggleGroup/@tab2/@tabText2").gameObject;
		self.tab3 = self.transform:FindChild("left/toggleGroup/@tab3").gameObject;
		self.tabText3 = self.transform:FindChild("left/toggleGroup/@tab3/@tabText3").gameObject;
		self.toggleLight = self.transform:FindChild("left/toggleGroup/@toggleLight").gameObject;
		self.toggleLightText = self.transform:FindChild("left/toggleGroup/@toggleLight/@toggleLightText").gameObject;
		self.contractPage = self.transform:FindChild("left/@contractPage").gameObject;
		self.friendsGroup = self.transform:FindChild("left/@contractPage/@friendsGroup").gameObject;
		self.friendsBg = self.transform:FindChild("left/@contractPage/@friendsGroup/@friendsBg").gameObject;
		self.friendsGroupDes = self.transform:FindChild("left/@contractPage/@friendsGroup/@friendsBg/@friendsGroupDes").gameObject;
		self.contractScrollView = self.transform:FindChild("left/@contractPage/@contractScrollView").gameObject;
		self.blacklistGroup = self.transform:FindChild("left/@contractPage/@blacklistGroup").gameObject;
		self.blacklistBg = self.transform:FindChild("left/@contractPage/@blacklistGroup/@blacklistBg").gameObject;
		self.blacklistGroupDes = self.transform:FindChild("left/@contractPage/@blacklistGroup/@blacklistBg/@blacklistGroupDes").gameObject;
		self.enemysGroup = self.transform:FindChild("left/@contractPage/@enemysGroup").gameObject;
		self.enemysBg = self.transform:FindChild("left/@contractPage/@enemysGroup/@enemysBg").gameObject;
		self.enemysGroupDes = self.transform:FindChild("left/@contractPage/@enemysGroup/@enemysBg/@enemysGroupDes").gameObject;
		self.btnFriendAdd = self.transform:FindChild("left/@btnFriendAdd").gameObject;
		self.btnFriendApply = self.transform:FindChild("left/@btnFriendApply").gameObject;
		self.applyRedDot = self.transform:FindChild("left/reddot/@applyRedDot").gameObject;
		self.applyCountText = self.transform:FindChild("left/reddot/@applyRedDot/@applyCountText").gameObject;
		self.subPageTitle = self.transform:FindChild("title/@subPageTitle").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
	end
	return self;
end
FriendsUI = FriendsUI or CreateFriendsUI();
