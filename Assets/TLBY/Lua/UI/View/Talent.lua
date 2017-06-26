----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTalent()
	local self = CreateViewBase();
	self.Awake = function()
		self.talentmainui = self.transform:FindChild("@talentmainui").gameObject;
		self.talent3ui = self.transform:FindChild("@talentmainui/@talent3ui").gameObject;
		self.talent2ui = self.transform:FindChild("@talentmainui/@talent2ui").gameObject;
		self.talent1ui = self.transform:FindChild("@talentmainui/@talent1ui").gameObject;
		self.talent1name = self.transform:FindChild("@talentmainui/@talent1ui/@talent1name").gameObject;
		self.texttalent1Vertical1 = self.transform:FindChild("@talentmainui/@talent1ui/@texttalent1Vertical1").gameObject;
		self.texttalent1Vertical2 = self.transform:FindChild("@talentmainui/@talent1ui/@texttalent1Vertical2").gameObject;
		self.texttalent1Vertical3 = self.transform:FindChild("@talentmainui/@talent1ui/@texttalent1Vertical3").gameObject;
		self.texttalent1Vertical4 = self.transform:FindChild("@talentmainui/@talent1ui/@texttalent1Vertical4").gameObject;
		self.btnactivation1 = self.transform:FindChild("@talentmainui/@btnactivation1").gameObject;
		self.btnactivation2 = self.transform:FindChild("@talentmainui/@btnactivation2").gameObject;
		self.btnactivation3 = self.transform:FindChild("@talentmainui/@btnactivation3").gameObject;
		self.texttips = self.transform:FindChild("@talentmainui/@texttips").gameObject;
		self.confirmactivationui = self.transform:FindChild("@confirmactivationui").gameObject;
		self.btnconfirm_tip = self.transform:FindChild("@confirmactivationui/@btnconfirm_tip").gameObject;
		self.btnclose_tip = self.transform:FindChild("@confirmactivationui/@btnclose_tip").gameObject;
		self.btnrule = self.transform:FindChild("@btnrule").gameObject;
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.scoreui = self.transform:FindChild("@scoreui").gameObject;
	end
	return self;
end
Talent = Talent or CreateTalent();
