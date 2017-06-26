----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateArenaSelect()
	local self = CreateViewBase();
	self.Awake = function()
		self.texttitle = self.transform:FindChild("@texttitle").gameObject;
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.btnpage1 = self.transform:FindChild("@btnpage1").gameObject;
		self.textpage1 = self.transform:FindChild("@btnpage1/@textpage1").gameObject;
		self.pagepanel1 = self.transform:FindChild("@btnpage1/@pagepanel1").gameObject;
		self.btnRankingbattle = self.transform:FindChild("@btnpage1/@pagepanel1/@btnRankingbattle").gameObject;
		self.textbattlefrequency = self.transform:FindChild("@btnpage1/@pagepanel1/@textbattlefrequency").gameObject;
		self.btnadd1 = self.transform:FindChild("@btnpage1/@pagepanel1/@btnadd1").gameObject;
		self.btnwildwar = self.transform:FindChild("@btnpage1/@pagepanel1/@btnwildwar").gameObject;
		self.textopentime = self.transform:FindChild("@btnpage1/@pagepanel1/@textopentime").gameObject;
		self.textbattlecondition = self.transform:FindChild("@btnpage1/@pagepanel1/@textbattlecondition").gameObject;
		self.btnadd2 = self.transform:FindChild("@btnpage1/@pagepanel1/@btnadd2").gameObject;
		self.btncommon1_1 = self.transform:FindChild("@btnpage1/@pagepanel1/@btncommon1_1").gameObject;
		self.textbtncommon1 = self.transform:FindChild("@btnpage1/@pagepanel1/@textbtncommon1").gameObject;
		self.btnpage2 = self.transform:FindChild("@btnpage2").gameObject;
		self.textpage2 = self.transform:FindChild("@btnpage2/@textpage2").gameObject;
		self.btnpage3 = self.transform:FindChild("@btnpage3").gameObject;
		self.textpage3 = self.transform:FindChild("@btnpage3/@textpage3").gameObject;
		self.btnpage4 = self.transform:FindChild("@btnpage4").gameObject;
		self.textpage4 = self.transform:FindChild("@btnpage4/@textpage4").gameObject;
		self.btnpage5 = self.transform:FindChild("@btnpage5").gameObject;
		self.textpage5 = self.transform:FindChild("@btnpage5/@textpage5").gameObject;
		self.btnpage6 = self.transform:FindChild("@btnpage6").gameObject;
		self.textpage6 = self.transform:FindChild("@btnpage6/@textpage6").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
	end
	return self;
end
ArenaSelect = ArenaSelect or CreateArenaSelect();
