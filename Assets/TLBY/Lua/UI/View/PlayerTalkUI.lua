----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePlayerTalkUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.selfTalk = self.transform:FindChild("@selfTalk").gameObject;
		self.systemInfo = self.transform:FindChild("@systemInfo").gameObject;
		self.otherTalk = self.transform:FindChild("@otherTalk").gameObject;
		self.btntimenumber = self.transform:FindChild("@otherTalk/btntrumpet/@btntimenumber").gameObject;
		self.dateItem = self.transform:FindChild("@dateItem").gameObject;
		self.title = self.transform:FindChild("@title").gameObject;
		self.friendValue = self.transform:FindChild("@friendValue").gameObject;
		self.scrollview = self.transform:FindChild("@scrollview").gameObject;
		self.talkList = self.transform:FindChild("@scrollview/Viewport/@talkList").gameObject;
		self.inputField = self.transform:FindChild("bottom/@inputField").gameObject;
		self.btnVoice = self.transform:FindChild("bottom/@btnVoice").gameObject;
		self.btnAdd = self.transform:FindChild("bottom/@btnAdd").gameObject;
		self.btnSend = self.transform:FindChild("bottom/@btnSend").gameObject;
	end
	return self;
end
PlayerTalkUI = PlayerTalkUI or CreatePlayerTalkUI();
