----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateArenaRankList()
	local self = CreateViewBase();
	self.Awake = function()
		self.wildwarui = self.transform:FindChild("@wildwarui").gameObject;
		self.singleUI = self.transform:FindChild("@wildwarui/@singleUI").gameObject;
		self.rankGroup = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup").gameObject;
		self.btntranspaging1 = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup/@btntranspaging1").gameObject;
		self.textbtntranspaging1 = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup/@btntranspaging1/@textbtntranspaging1").gameObject;
		self.btntranspaging2 = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup/@btntranspaging2").gameObject;
		self.textbtntranspaging2 = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup/@btntranspaging2/@textbtntranspaging2").gameObject;
		self.btntranspaging3 = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup/@btntranspaging3").gameObject;
		self.textbtntranspaging3 = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup/@btntranspaging3/@textbtntranspaging3").gameObject;
		self.btntranspaging4 = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup/@btntranspaging4").gameObject;
		self.textbtntranspaging4 = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup/@btntranspaging4/@textbtntranspaging4").gameObject;
		self.btntranspaging5 = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup/@btntranspaging5").gameObject;
		self.textbtntranspaging5 = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup/@btntranspaging5/@textbtntranspaging5").gameObject;
		self.btntranspaging6 = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup/@btntranspaging6").gameObject;
		self.textbtntranspaging6 = self.transform:FindChild("@wildwarui/@singleUI/@rankGroup/@btntranspaging6/@textbtntranspaging6").gameObject;
		self.secondRankGroup = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup").gameObject;
		self.btnpaging1 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging1").gameObject;
		self.textbtnpaging1 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging1/@textbtnpaging1").gameObject;
		self.btnpaging2 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging2").gameObject;
		self.textbtnpaging2 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging2/@textbtnpaging2").gameObject;
		self.btnpaging3 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging3").gameObject;
		self.textbtnpaging3 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging3/@textbtnpaging3").gameObject;
		self.btnpaging4 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging4").gameObject;
		self.textbtnpaging4 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging4/@textbtnpaging4").gameObject;
		self.btnpaging5 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging5").gameObject;
		self.textbtnpaging5 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging5/@textbtnpaging5").gameObject;
		self.btnpaging6 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging6").gameObject;
		self.textbtnpaging6 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging6/@textbtnpaging6").gameObject;
		self.btnpaging7 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging7").gameObject;
		self.textbtnpaging7 = self.transform:FindChild("@wildwarui/@singleUI/@secondRankGroup/@btnpaging7/@textbtnpaging7").gameObject;
		self.rankFieldGroup = self.transform:FindChild("@wildwarui/@singleUI/@rankFieldGroup").gameObject;
		self.textranking = self.transform:FindChild("@wildwarui/@singleUI/@rankFieldGroup/@textranking").gameObject;
		self.textname = self.transform:FindChild("@wildwarui/@singleUI/@rankFieldGroup/@textname").gameObject;
		self.textlv = self.transform:FindChild("@wildwarui/@singleUI/@rankFieldGroup/@textlv").gameObject;
		self.textparty = self.transform:FindChild("@wildwarui/@singleUI/@rankFieldGroup/@textparty").gameObject;
		self.textfamily = self.transform:FindChild("@wildwarui/@singleUI/@rankFieldGroup/@textfamily").gameObject;
		self.texttotal = self.transform:FindChild("@wildwarui/@singleUI/@rankFieldGroup/@texttotal").gameObject;
		self.selfRankGroup = self.transform:FindChild("@wildwarui/@singleUI/@selfRankGroup").gameObject;
		self.rankScrollview = self.transform:FindChild("@wildwarui/@singleUI/@rankScrollview").gameObject;
		self.itemTemplate = self.transform:FindChild("@wildwarui/@singleUI/@rankScrollview/Viewport/Content/@itemTemplate").gameObject;
		self.texttitle = self.transform:FindChild("@wildwarui/@texttitle").gameObject;
		self.btnReturn = self.transform:FindChild("@wildwarui/@btnReturn").gameObject;
		self.btnrule = self.transform:FindChild("@wildwarui/@btnrule").gameObject;
		self.testRefreshTime = self.transform:FindChild("@wildwarui/@testRefreshTime").gameObject;
	end
	return self;
end
ArenaRankList = ArenaRankList or CreateArenaRankList();
