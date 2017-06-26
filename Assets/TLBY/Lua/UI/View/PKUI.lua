----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePKUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.interfacebg = self.transform:FindChild("@interfacebg").gameObject;
		self.btnclose = self.transform:FindChild("@btnclose").gameObject;
		self.classificationui = self.transform:FindChild("@classificationui").gameObject;
		self.btnmode1 = self.transform:FindChild("@classificationui/bgsmall1/@btnmode1").gameObject;
		self.btnmode2 = self.transform:FindChild("@classificationui/bgsmall2/@btnmode2").gameObject;
		self.btnmode3 = self.transform:FindChild("@classificationui/bgsmal3/@btnmode3").gameObject;
		self.btnmode4 = self.transform:FindChild("@classificationui/bgsmall4/@btnmode4").gameObject;
		self.textdescribe = self.transform:FindChild("@classificationui/@textdescribe").gameObject;
		self.textpknumber = self.transform:FindChild("@classificationui/@textpknumber").gameObject;
		self.textExplain = self.transform:FindChild("@classificationui/@textExplain").gameObject;
		self.btnback = self.transform:FindChild("@btnback").gameObject;
		self.textback = self.transform:FindChild("@btnback/@textback").gameObject;
		self.btndetermine = self.transform:FindChild("@btndetermine").gameObject;
		self.textdetermine = self.transform:FindChild("@btndetermine/@textdetermine").gameObject;
		self.btnrules = self.transform:FindChild("@btnrules").gameObject;
	end
	return self;
end
PKUI = PKUI or CreatePKUI();
