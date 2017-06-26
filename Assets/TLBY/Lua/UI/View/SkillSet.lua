----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateSkillSet()
	local self = CreateViewBase();
	self.Awake = function()
		self.upgradeui = self.transform:FindChild("@upgradeui").gameObject;
		self.btnupgrade = self.transform:FindChild("@upgradeui/@btnupgrade").gameObject;
		self.textupgrade = self.transform:FindChild("@upgradeui/@textupgrade").gameObject;
		self.item1 = self.transform:FindChild("@upgradeui/@item1").gameObject;
		self.textconsume1 = self.transform:FindChild("@upgradeui/@item1/@textconsume1").gameObject;
		self.textHave1 = self.transform:FindChild("@upgradeui/@item1/@textHave1").gameObject;
		self.iconconsume1 = self.transform:FindChild("@upgradeui/@item1/@iconconsume1").gameObject;
		self.texticonconsume1 = self.transform:FindChild("@upgradeui/@item1/@texticonconsume1").gameObject;
		self.item2 = self.transform:FindChild("@upgradeui/@item2").gameObject;
		self.textconsume2 = self.transform:FindChild("@upgradeui/@item2/@textconsume2").gameObject;
		self.textHave2 = self.transform:FindChild("@upgradeui/@item2/@textHave2").gameObject;
		self.iconconsume2 = self.transform:FindChild("@upgradeui/@item2/@iconconsume2").gameObject;
		self.texticonconsume2 = self.transform:FindChild("@upgradeui/@item2/@texticonconsume2").gameObject;
		self.textupgradename = self.transform:FindChild("@upgradeui/@textupgradename").gameObject;
		self.useingui = self.transform:FindChild("@useingui").gameObject;
		self.textskillname = self.transform:FindChild("@useingui/@textskillname").gameObject;
		self.textuseingtips = self.transform:FindChild("@useingui/@textuseingtips").gameObject;
		self.btnuseing = self.transform:FindChild("@useingui/@textuseingtips/@btnuseing").gameObject;
		self.textuseing = self.transform:FindChild("@useingui/@textuseingtips/@textuseing").gameObject;
		self.textskilldescribe = self.transform:FindChild("@useingui/Scroll View/Viewport/@textskilldescribe").gameObject;
		self.picusing = self.transform:FindChild("@useingui/@picusing").gameObject;
		self.chooseTacticui = self.transform:FindChild("@chooseTacticui").gameObject;
		self.choosegroup1 = self.transform:FindChild("@chooseTacticui/@choosegroup1").gameObject;
		self.choosegroup2 = self.transform:FindChild("@chooseTacticui/@choosegroup2").gameObject;
		self.choosegroup3 = self.transform:FindChild("@chooseTacticui/@choosegroup3").gameObject;
		self.choosegroup4 = self.transform:FindChild("@chooseTacticui/@choosegroup4").gameObject;
		self.Tacticskillui = self.transform:FindChild("@Tacticskillui").gameObject;
		self.slotgroup1 = self.transform:FindChild("@Tacticskillui/@slotgroup1").gameObject;
		self.slotgroup2 = self.transform:FindChild("@Tacticskillui/@slotgroup2").gameObject;
		self.slotgroup3 = self.transform:FindChild("@Tacticskillui/@slotgroup3").gameObject;
		self.slotgroup4 = self.transform:FindChild("@Tacticskillui/@slotgroup4").gameObject;
		self.btnOthersects = self.transform:FindChild("@Tacticskillui/@btnOthersects").gameObject;
		self.textOthersects = self.transform:FindChild("@Tacticskillui/@textOthersects").gameObject;
		self.textuseingskill = self.transform:FindChild("@Tacticskillui/@textuseingskill").gameObject;
		self.Tacticui = self.transform:FindChild("@Tacticui").gameObject;
		self.btnTactic = self.transform:FindChild("@Tacticui/@btnTactic").gameObject;
		self.skillgroup1 = self.transform:FindChild("@Tacticui/@skillgroup1").gameObject;
		self.skillgroup2 = self.transform:FindChild("@Tacticui/@skillgroup2").gameObject;
		self.skillgroup3 = self.transform:FindChild("@Tacticui/@skillgroup3").gameObject;
		self.skillgroup4 = self.transform:FindChild("@Tacticui/@skillgroup4").gameObject;
		self.textTacticname = self.transform:FindChild("@Tacticui/@textTacticname").gameObject;
		self.textTacticdescribe = self.transform:FindChild("@Tacticui/@textTacticdescribe").gameObject;
		self.textTacticlv = self.transform:FindChild("@Tacticui/@textTacticlv").gameObject;
		self.btnTacticSelected = self.transform:FindChild("@Tacticui/@btnTacticSelected").gameObject;
		self.LoadProjectui = self.transform:FindChild("@LoadProjectui").gameObject;
		self.textLoadProject = self.transform:FindChild("@LoadProjectui/@textLoadProject").gameObject;
		self.itemtemplate = self.transform:FindChild("@LoadProjectui/Scroll View/Viewport/Content/@itemtemplate").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
		self.btnclose = self.transform:FindChild("@btnclose").gameObject;
		self.effectupgrade = self.transform:FindChild("@effectupgrade").gameObject;
		self.effectupgradeskill1 = self.transform:FindChild("@effectupgrade/@effectupgradeskill1").gameObject;
		self.effectupgradeskill2 = self.transform:FindChild("@effectupgrade/@effectupgradeskill2").gameObject;
		self.effectupgradeskill3 = self.transform:FindChild("@effectupgrade/@effectupgradeskill3").gameObject;
		self.effectupgradeskill4 = self.transform:FindChild("@effectupgrade/@effectupgradeskill4").gameObject;
		self.effectupgradeall = self.transform:FindChild("@effectupgrade/@effectupgradeall").gameObject;
	end
	return self;
end
SkillSet = SkillSet or CreateSkillSet();
