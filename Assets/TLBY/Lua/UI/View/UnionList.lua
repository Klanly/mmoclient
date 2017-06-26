----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateUnionList()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.signupbtn = self.transform:FindChild("bgrightbackground/@signupbtn").gameObject;
		self.calluniononwerbtn = self.transform:FindChild("bgrightbackground/@calluniononwerbtn").gameObject;
		self.createunionbtn = self.transform:FindChild("bgrightbackground/@createunionbtn").gameObject;
		self.unionnotice = self.transform:FindChild("bgrightbackground/@unionnotice").gameObject;
		self.textDramaticlist = self.transform:FindChild("bgrightbackground/@textDramaticlist").gameObject;
		self.enemyunion = self.transform:FindChild("bgrightbackground/@enemyunion").gameObject;
		self.textRivalgang = self.transform:FindChild("bgrightbackground/@textRivalgang").gameObject;
		self.btnkeyapplication = self.transform:FindChild("bgleftbackground/@btnkeyapplication").gameObject;
		self.btnsearch = self.transform:FindChild("bgleftbackground/@btnsearch").gameObject;
		self.SearchInput = self.transform:FindChild("bgleftbackground/@SearchInput").gameObject;
		self.UnionListScrollview = self.transform:FindChild("bgleftbackground/@UnionListScrollview").gameObject;
		self.rankitem = self.transform:FindChild("bgleftbackground/@UnionListScrollview/Viewport/Content/@rankitem").gameObject;
	end
	return self;
end
UnionList = UnionList or CreateUnionList();
