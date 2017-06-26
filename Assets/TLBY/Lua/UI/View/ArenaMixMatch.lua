----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateArenaMixMatch()
	local self = CreateViewBase();
	self.Awake = function()
		self.wildwarui = self.transform:FindChild("@wildwarui").gameObject;
		self.testRefreshTime = self.transform:FindChild("@wildwarui/@testRefreshTime").gameObject;
		self.matchui = self.transform:FindChild("@wildwarui/@matchui").gameObject;
		self.btnRankingList = self.transform:FindChild("@wildwarui/@matchui/@btnRankingList").gameObject;
		self.btnStartmatching = self.transform:FindChild("@wildwarui/@matchui/@btnStartmatching").gameObject;
		self.textbtnStartmatching = self.transform:FindChild("@wildwarui/@matchui/@textbtnStartmatching").gameObject;
		self.textinformation = self.transform:FindChild("@wildwarui/@matchui/@textinformation").gameObject;
		self.textmyfctitle = self.transform:FindChild("@wildwarui/@matchui/@textmyfctitle").gameObject;
		self.textfctitle = self.transform:FindChild("@wildwarui/@matchui/@textfctitle").gameObject;
		self.textResidualfrequency = self.transform:FindChild("@wildwarui/@matchui/@textResidualfrequency").gameObject;
		self.btnadd = self.transform:FindChild("@wildwarui/@matchui/@btnadd").gameObject;
		self.texbtnRankingList1 = self.transform:FindChild("@wildwarui/@matchui/@texbtnRankingList1").gameObject;
		self.texbtnRankingList2 = self.transform:FindChild("@wildwarui/@matchui/@texbtnRankingList2").gameObject;
		self.textQualifyingtiele = self.transform:FindChild("@wildwarui/@matchui/@textQualifyingtiele").gameObject;
		self.testUsedtime = self.transform:FindChild("@wildwarui/@matchui/@testUsedtime").gameObject;
		self.textEstimatedtime = self.transform:FindChild("@wildwarui/@matchui/@textEstimatedtime").gameObject;
		self.btnshop = self.transform:FindChild("@wildwarui/@matchui/@btnshop").gameObject;
		self.textArenastore = self.transform:FindChild("@wildwarui/@matchui/@textArenastore").gameObject;
		self.mixUI = self.transform:FindChild("@wildwarui/@mixUI").gameObject;
		self.rankFieldGroup = self.transform:FindChild("@wildwarui/@mixUI/@rankFieldGroup").gameObject;
		self.textranking = self.transform:FindChild("@wildwarui/@mixUI/@rankFieldGroup/@textranking").gameObject;
		self.textname = self.transform:FindChild("@wildwarui/@mixUI/@rankFieldGroup/@textname").gameObject;
		self.textlv = self.transform:FindChild("@wildwarui/@mixUI/@rankFieldGroup/@textlv").gameObject;
		self.textparty = self.transform:FindChild("@wildwarui/@mixUI/@rankFieldGroup/@textparty").gameObject;
		self.textfamily = self.transform:FindChild("@wildwarui/@mixUI/@rankFieldGroup/@textfamily").gameObject;
		self.textscore1 = self.transform:FindChild("@wildwarui/@mixUI/@rankFieldGroup/@textscore1").gameObject;
		self.textscore2 = self.transform:FindChild("@wildwarui/@mixUI/@rankFieldGroup/@textscore2").gameObject;
		self.texttotal = self.transform:FindChild("@wildwarui/@mixUI/@rankFieldGroup/@texttotal").gameObject;
		self.rankScrollview = self.transform:FindChild("@wildwarui/@mixUI/@rankScrollview").gameObject;
		self.itemTemplate = self.transform:FindChild("@wildwarui/@mixUI/@rankScrollview/Viewport/Content/@itemTemplate").gameObject;
		self.selfRankGroup = self.transform:FindChild("@wildwarui/@mixUI/@selfRankGroup").gameObject;
		self.texttitle = self.transform:FindChild("@wildwarui/@texttitle").gameObject;
		self.btnReturn = self.transform:FindChild("@wildwarui/@btnReturn").gameObject;
		self.btnrule = self.transform:FindChild("@wildwarui/@btnrule").gameObject;
	end
	return self;
end
ArenaMixMatch = ArenaMixMatch or CreateArenaMixMatch();
