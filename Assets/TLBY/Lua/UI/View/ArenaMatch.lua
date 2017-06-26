----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateArenaMatch()
	local self = CreateViewBase();
	self.Awake = function()
		self.Rankingwarui = self.transform:FindChild("@Rankingwarui").gameObject;
		self.texttitle = self.transform:FindChild("@Rankingwarui/@texttitle").gameObject;
		self.matchui = self.transform:FindChild("@Rankingwarui/@matchui").gameObject;
		self.btnresettime = self.transform:FindChild("@Rankingwarui/@matchui/@btnresettime").gameObject;
		self.textresettime = self.transform:FindChild("@Rankingwarui/@matchui/@textresettime").gameObject;
		self.textresttimeCost = self.transform:FindChild("@Rankingwarui/@matchui/@textresettime/@textresttimeCost").gameObject;
		self.btnrefreshplayer = self.transform:FindChild("@Rankingwarui/@matchui/@btnrefreshplayer").gameObject;
		self.textrefreshplayer = self.transform:FindChild("@Rankingwarui/@matchui/@textrefreshplayer").gameObject;
		self.textrankingtitle = self.transform:FindChild("@Rankingwarui/@matchui/@textrankingtitle").gameObject;
		self.textranking = self.transform:FindChild("@Rankingwarui/@matchui/@textranking").gameObject;
		self.textmyfctitle = self.transform:FindChild("@Rankingwarui/@matchui/@textmyfctitle").gameObject;
		self.textfctitle = self.transform:FindChild("@Rankingwarui/@matchui/@textfctitle").gameObject;
		self.textResidualfrequency = self.transform:FindChild("@Rankingwarui/@matchui/@textResidualfrequency").gameObject;
		self.textDekarontime = self.transform:FindChild("@Rankingwarui/@matchui/@textDekarontime").gameObject;
		self.btnadd = self.transform:FindChild("@Rankingwarui/@matchui/@btnadd").gameObject;
		self.btnRankingList = self.transform:FindChild("@Rankingwarui/@matchui/@btnRankingList").gameObject;
		self.texbtnRankingList1 = self.transform:FindChild("@Rankingwarui/@matchui/@texbtnRankingList1").gameObject;
		self.texbtnRankingLis2 = self.transform:FindChild("@Rankingwarui/@matchui/@texbtnRankingLis2").gameObject;
		self.textQualifyingtiele = self.transform:FindChild("@Rankingwarui/@matchui/@textQualifyingtiele").gameObject;
		self.playerGroup = self.transform:FindChild("@Rankingwarui/@playerGroup").gameObject;
		self.player1 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player1").gameObject;
		self.textname1 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player1/@textname1").gameObject;
		self.level1 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player1/@level1").gameObject;
		self.rank1 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player1/@rank1").gameObject;
		self.sprite1 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player1/@sprite1").gameObject;
		self.head1 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player1/@head1").gameObject;
		self.btnfight1 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player1/@btnfight1").gameObject;
		self.player2 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player2").gameObject;
		self.textname2 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player2/@textname2").gameObject;
		self.level2 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player2/@level2").gameObject;
		self.rank2 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player2/@rank2").gameObject;
		self.sprite2 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player2/@sprite2").gameObject;
		self.head2 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player2/@head2").gameObject;
		self.btnfight2 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player2/@btnfight2").gameObject;
		self.player3 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player3").gameObject;
		self.textname3 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player3/@textname3").gameObject;
		self.level3 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player3/@level3").gameObject;
		self.rank3 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player3/@rank3").gameObject;
		self.sprite3 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player3/@sprite3").gameObject;
		self.head3 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player3/@head3").gameObject;
		self.btnfight3 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player3/@btnfight3").gameObject;
		self.player4 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player4").gameObject;
		self.textname4 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player4/@textname4").gameObject;
		self.level4 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player4/@level4").gameObject;
		self.rank4 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player4/@rank4").gameObject;
		self.sprite4 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player4/@sprite4").gameObject;
		self.head4 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player4/@head4").gameObject;
		self.btnfight4 = self.transform:FindChild("@Rankingwarui/@playerGroup/@player4/@btnfight4").gameObject;
		self.btnReturn = self.transform:FindChild("@Rankingwarui/@btnReturn").gameObject;
		self.btnrule = self.transform:FindChild("@Rankingwarui/@btnrule").gameObject;
		self.btnsetteam = self.transform:FindChild("@Rankingwarui/@btnsetteam").gameObject;
		self.textsetteam = self.transform:FindChild("@Rankingwarui/@textsetteam").gameObject;
		self.textIntegralshop = self.transform:FindChild("@Rankingwarui/@textIntegralshop").gameObject;
	end
	return self;
end
ArenaMatch = ArenaMatch or CreateArenaMatch();
