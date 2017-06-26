----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTeamConfirmUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.targetName = self.transform:FindChild("@targetName").gameObject;
		self.timer = self.transform:FindChild("@timer").gameObject;
		self.item1 = self.transform:FindChild("image/@item1").gameObject;
		self.item2 = self.transform:FindChild("image/@item2").gameObject;
		self.item3 = self.transform:FindChild("image/@item3").gameObject;
		self.item4 = self.transform:FindChild("image/@item4").gameObject;
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.text1 = self.transform:FindChild("@text1").gameObject;
		self.text2 = self.transform:FindChild("@text2").gameObject;
		self.note1 = self.transform:FindChild("@note1").gameObject;
		self.note2 = self.transform:FindChild("@note2").gameObject;
		self.btnCancel = self.transform:FindChild("@btnCancel").gameObject;
		self.btnAgree = self.transform:FindChild("@btnAgree").gameObject;
		self.awardNote = self.transform:FindChild("@awardNote").gameObject;
	end
	return self;
end
TeamConfirmUI = TeamConfirmUI or CreateTeamConfirmUI();
