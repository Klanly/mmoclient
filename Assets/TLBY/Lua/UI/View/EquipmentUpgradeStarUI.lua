----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateEquipmentUpgradeStarUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.upgradestarui = self.transform:FindChild("@upgradestarui").gameObject;
		self.textBlessingdescribe = self.transform:FindChild("@upgradestarui/@textBlessingdescribe").gameObject;
		self.star1 = self.transform:FindChild("@upgradestarui/star/@star1").gameObject;
		self.star2 = self.transform:FindChild("@upgradestarui/star/@star2").gameObject;
		self.star3 = self.transform:FindChild("@upgradestarui/star/@star3").gameObject;
		self.star4 = self.transform:FindChild("@upgradestarui/star/@star4").gameObject;
		self.star5 = self.transform:FindChild("@upgradestarui/star/@star5").gameObject;
		self.star6 = self.transform:FindChild("@upgradestarui/star/@star6").gameObject;
		self.star7 = self.transform:FindChild("@upgradestarui/star/@star7").gameObject;
		self.star8 = self.transform:FindChild("@upgradestarui/star/@star8").gameObject;
		self.star9 = self.transform:FindChild("@upgradestarui/star/@star9").gameObject;
		self.darkstar = self.transform:FindChild("@upgradestarui/star/@darkstar").gameObject;
		self.bgiconPrayermaterial = self.transform:FindChild("@upgradestarui/@bgiconPrayermaterial").gameObject;
		self.iconPrayermaterialQuality = self.transform:FindChild("@upgradestarui/@iconPrayermaterialQuality").gameObject;
		self.iconPrayermaterial = self.transform:FindChild("@upgradestarui/@iconPrayermaterial").gameObject;
		self.btnPrayermaterialadd = self.transform:FindChild("@upgradestarui/@btnPrayermaterialadd").gameObject;
		self.bgiconStrengthenstone2 = self.transform:FindChild("@upgradestarui/@bgiconStrengthenstone2").gameObject;
		self.iconStrengthenstoneQuality2 = self.transform:FindChild("@upgradestarui/@iconStrengthenstoneQuality2").gameObject;
		self.iconStrengthenstone2 = self.transform:FindChild("@upgradestarui/@iconStrengthenstone2").gameObject;
		self.btndetermine = self.transform:FindChild("@upgradestarui/@btndetermine").gameObject;
		self.textdetermine = self.transform:FindChild("@upgradestarui/@textdetermine").gameObject;
		self.bgstarexparticle1 = self.transform:FindChild("@upgradestarui/@bgstarexparticle1").gameObject;
		self.bgstarexparticle = self.transform:FindChild("@upgradestarui/@bgstarexparticle").gameObject;
		self.textstarexparticle = self.transform:FindChild("@upgradestarui/@textstarexparticle").gameObject;
		self.starexparticle = self.transform:FindChild("@upgradestarui/@starexparticle").gameObject;
		self.textblessnumber = self.transform:FindChild("@upgradestarui/@textblessnumber").gameObject;
		self.effectUpgradeStar = self.transform:FindChild("@upgradestarui/@effectUpgradeStar").gameObject;
		self.effectCamera = self.transform:FindChild("@upgradestarui/@effectUpgradeStar/@effectCamera").gameObject;
		self.glow_common = self.transform:FindChild("@upgradestarui/@effectUpgradeStar/@glow_common").gameObject;
		self.shengxing_critical = self.transform:FindChild("@upgradestarui/@effectUpgradeStar/@shengxing_critical").gameObject;
		self.shengxing_star = self.transform:FindChild("@upgradestarui/@effectUpgradeStar/@shengxing_star").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
		self.btnclose = self.transform:FindChild("@btnclose").gameObject;
	end
	return self;
end
EquipmentUpgradeStarUI = EquipmentUpgradeStarUI or CreateEquipmentUpgradeStarUI();
