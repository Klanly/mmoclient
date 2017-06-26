----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateChallengeUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.chaptersSv = self.transform:FindChild("Chapters/@chaptersSv").gameObject;
		self.ChapterItem = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@ChapterItem").gameObject;
		self.txtChapterName = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@ChapterItem/@txtChapterName").gameObject;
		self.txtChapterIndex = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@ChapterItem/@txtChapterIndex").gameObject;
		self.txtStarCount = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@ChapterItem/@txtStarCount").gameObject;
		self.sectionLock = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionLock").gameObject;
		self.sectionItem = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem").gameObject;
		self.sectionContent = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent").gameObject;
		self.bgoverlord = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent/@bgoverlord").gameObject;
		self.overlord = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent/@overlord").gameObject;
		self.overlordname = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent/@overlordname").gameObject;
		self.textoverlordtitle = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent/@textoverlordtitle").gameObject;
		self.rating1 = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent/@rating1").gameObject;
		self.rating2 = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent/@rating2").gameObject;
		self.rating3 = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent/@rating3").gameObject;
		self.star2 = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent/bgstar/@star2").gameObject;
		self.star1 = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent/bgstar/@star1").gameObject;
		self.starno = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent/bgstar/@starno").gameObject;
		self.txtSectionName = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent/@txtSectionName").gameObject;
		self.txtSectionLevel = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@sectionContent/@txtSectionLevel").gameObject;
		self.imgChapterSelect = self.transform:FindChild("Chapters/@chaptersSv/Viewport/Content/@sectionItem/@imgChapterSelect").gameObject;
		self.descrGroup = self.transform:FindChild("@descrGroup").gameObject;
		self.textReward = self.transform:FindChild("@descrGroup/rewards/@textReward").gameObject;
		self.rewardContent = self.transform:FindChild("@descrGroup/rewards/Scroll View/Viewport/@rewardContent").gameObject;
		self.rewardItemTemplate = self.transform:FindChild("@descrGroup/rewards/Scroll View/Viewport/@rewardContent/@rewardItemTemplate").gameObject;
		self.equipmentdrop = self.transform:FindChild("@descrGroup/rewards/Scroll View/Viewport/@rewardContent/@rewardItemTemplate/@equipmentdrop").gameObject;
		self.textprobability = self.transform:FindChild("@descrGroup/rewards/Scroll View/Viewport/@rewardContent/@rewardItemTemplate/@textprobability").gameObject;
		self.txtDesc = self.transform:FindChild("@descrGroup/Scroll View/Viewport/@txtDesc").gameObject;
		self.txtSectionTitle = self.transform:FindChild("@descrGroup/@txtSectionTitle").gameObject;
		self.sectionName = self.transform:FindChild("@descrGroup/@sectionName").gameObject;
		self.btnSweeping = self.transform:FindChild("@descrGroup/@btnSweeping").gameObject;
		self.txtSweeping = self.transform:FindChild("@descrGroup/@txtSweeping").gameObject;
		self.txtRemainCount = self.transform:FindChild("@descrGroup/@txtRemainCount").gameObject;
		self.txtSweepingEnergy = self.transform:FindChild("@descrGroup/@txtSweepingEnergy").gameObject;
		self.selectChapterGroup = self.transform:FindChild("@selectChapterGroup").gameObject;
		self.btnMainline = self.transform:FindChild("@selectChapterGroup/@btnMainline").gameObject;
		self.btnTeam = self.transform:FindChild("@selectChapterGroup/@btnTeam").gameObject;
		self.imgSelectGroup = self.transform:FindChild("@selectChapterGroup/@imgSelectGroup").gameObject;
		self.btnEnter = self.transform:FindChild("enter/@btnEnter").gameObject;
		self.textEnter = self.transform:FindChild("enter/@textEnter").gameObject;
		self.textEnterEnergy = self.transform:FindChild("enter/@textEnterEnergy").gameObject;
		self.rewardLineGroup = self.transform:FindChild("@rewardLineGroup").gameObject;
		self.chapterRewardSv = self.transform:FindChild("@rewardLineGroup/@chapterRewardSv").gameObject;
		self.sRewardItem = self.transform:FindChild("@rewardLineGroup/@chapterRewardSv/Viewport/Content/@sRewardItem").gameObject;
		self.Progressrewardarticle = self.transform:FindChild("@rewardLineGroup/@chapterRewardSv/Viewport/Content/@sRewardItem/@Progressrewardarticle").gameObject;
		self.treasurechest = self.transform:FindChild("@rewardLineGroup/@chapterRewardSv/Viewport/Content/@sRewardItem/@treasurechest").gameObject;
		self.treasurechestlight = self.transform:FindChild("@rewardLineGroup/@chapterRewardSv/Viewport/Content/@sRewardItem/@treasurechestlight").gameObject;
		self.textSnumber = self.transform:FindChild("@rewardLineGroup/@chapterRewardSv/Viewport/Content/@sRewardItem/@textSnumber").gameObject;
		self.textCurSnum = self.transform:FindChild("@rewardLineGroup/@chapterRewardSv/Viewport/Content/@sRewardItem/@textCurSnum").gameObject;
		self.energyGroup = self.transform:FindChild("@energyGroup").gameObject;
		self.btnAddEnergy = self.transform:FindChild("@energyGroup/@btnAddEnergy").gameObject;
		self.texthpdigital = self.transform:FindChild("@energyGroup/@texthpdigital").gameObject;
		self.btnclose = self.transform:FindChild("@btnclose").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
	end
	return self;
end
ChallengeUI = ChallengeUI or CreateChallengeUI();
