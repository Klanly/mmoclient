----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateUnionAntagonizeSetting()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.setenemybtn = self.transform:FindChild("bgrightbackground/@setenemybtn").gameObject;
		self.refreshunionlist = self.transform:FindChild("bgrightbackground/@refreshunionlist").gameObject;
		self.unionnotice = self.transform:FindChild("bgrightbackground/@unionnotice").gameObject;
		self.enemyunion = self.transform:FindChild("bgrightbackground/@enemyunion").gameObject;
		self.SearchInput = self.transform:FindChild("bgleftbackground/@SearchInput").gameObject;
		self.btnkeyapplication = self.transform:FindChild("bgleftbackground/@btnkeyapplication").gameObject;
		self.btnsearch = self.transform:FindChild("bgleftbackground/@btnsearch").gameObject;
		self.UnionListScrollview = self.transform:FindChild("bgleftbackground/@UnionListScrollview").gameObject;
		self.rankitem = self.transform:FindChild("bgleftbackground/@UnionListScrollview/Viewport/Content/@rankitem").gameObject;
		self.myitem = self.transform:FindChild("bgleftbackground/@myitem").gameObject;
		self.bgblackarticle = self.transform:FindChild("bgleftbackground/@myitem/@bgblackarticle").gameObject;
		self.bgwhitearticle = self.transform:FindChild("bgleftbackground/@myitem/@bgwhitearticle").gameObject;
		self.bgselectarticle = self.transform:FindChild("bgleftbackground/@myitem/@bgselectarticle").gameObject;
		self.unionid = self.transform:FindChild("bgleftbackground/@myitem/@unionid").gameObject;
		self.unionname = self.transform:FindChild("bgleftbackground/@myitem/@unionname").gameObject;
		self.unionlevel = self.transform:FindChild("bgleftbackground/@myitem/@unionlevel").gameObject;
		self.unionnum = self.transform:FindChild("bgleftbackground/@myitem/@unionnum").gameObject;
		self.unionowner = self.transform:FindChild("bgleftbackground/@myitem/@unionowner").gameObject;
	end
	return self;
end
UnionAntagonizeSetting = UnionAntagonizeSetting or CreateUnionAntagonizeSetting();
