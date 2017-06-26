----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePetImproveUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.scoreUp = self.transform:FindChild("main/@scoreUp").gameObject;
		self.scoreUpPre = self.transform:FindChild("main/@scoreUp/@scoreUpPre").gameObject;
		self.scoreUpNext = self.transform:FindChild("main/@scoreUp/@scoreUpNext").gameObject;
		self.starUpgrade = self.transform:FindChild("main/@starUpgrade").gameObject;
		self.scoreLow = self.transform:FindChild("main/@starUpgrade/@scoreLow").gameObject;
		self.scoreLowPre = self.transform:FindChild("main/@starUpgrade/@scoreLow/@scoreLowPre").gameObject;
		self.scoreLowNext = self.transform:FindChild("main/@starUpgrade/@scoreLow/@scoreLowNext").gameObject;
		self.starNum = self.transform:FindChild("main/@starUpgrade/@starNum").gameObject;
		self.scrollView = self.transform:FindChild("main/@scrollView").gameObject;
		self.attributeItem = self.transform:FindChild("main/@scrollView/Viewport/content/@attributeItem").gameObject;
		self.starEffect = self.transform:FindChild("@starEffect").gameObject;
	end
	return self;
end
PetImproveUI = PetImproveUI or CreatePetImproveUI();
