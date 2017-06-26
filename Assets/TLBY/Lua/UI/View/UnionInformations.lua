----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateUnionInformations()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.textganginformation = self.transform:FindChild("@textganginformation").gameObject;
		self.conveyfortifiedpointbtn = self.transform:FindChild("bgrightbackground/@conveyfortifiedpointbtn").gameObject;
		self.buildunionbtn = self.transform:FindChild("bgrightbackground/@buildunionbtn").gameObject;
		self.infiefbtn = self.transform:FindChild("bgrightbackground/@infiefbtn").gameObject;
		self.unionnotice = self.transform:FindChild("bgrightbackground/@unionnotice").gameObject;
		self.enemyunion = self.transform:FindChild("bgrightbackground/@enemyunion").gameObject;
		self.setenemyunion = self.transform:FindChild("bgrightbackground/@setenemyunion").gameObject;
		self.editnotice = self.transform:FindChild("bgrightbackground/@editnotice").gameObject;
		self.noticeInput = self.transform:FindChild("bgrightbackground/@noticeInput").gameObject;
		self.textgrid = self.transform:FindChild("bgleftbackground/@textgrid").gameObject;
		self.btnArrow = self.transform:FindChild("bgleftbackground/@btnArrow").gameObject;
		self.unionname = self.transform:FindChild("bgleftbackground/baseinfo/@unionname").gameObject;
		self.unionowner = self.transform:FindChild("bgleftbackground/baseinfo/@unionowner").gameObject;
		self.unionlevel = self.transform:FindChild("bgleftbackground/baseinfo/@unionlevel").gameObject;
		self.unionid = self.transform:FindChild("bgleftbackground/baseinfo/@unionid").gameObject;
		self.unionfief = self.transform:FindChild("bgleftbackground/baseinfo/@unionfief").gameObject;
		self.unionum = self.transform:FindChild("bgleftbackground/baseinfo/@unionum").gameObject;
		self.textarenaranking = self.transform:FindChild("bgleftbackground/baseinfo/@textarenaranking").gameObject;
		self.faction_fund = self.transform:FindChild("bgleftbackground/architectureinfo/@faction_fund").gameObject;
		self.editunionname = self.transform:FindChild("bgleftbackground/@editunionname").gameObject;
		self.unionnameInput = self.transform:FindChild("bgleftbackground/@unionnameInput").gameObject;
	end
	return self;
end
UnionInformations = UnionInformations or CreateUnionInformations();
