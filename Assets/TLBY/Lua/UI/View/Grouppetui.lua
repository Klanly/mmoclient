----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateGrouppetui()
	local self = CreateViewBase();
	self.Awake = function()
		self.Grouppetui = self.transform:FindChild("@Grouppetui").gameObject;
		self.petblood = self.transform:FindChild("@Grouppetui/@petblood").gameObject;
		self.petblood = self.transform:FindChild("@Grouppetui/@petblood/@petblood").gameObject;
		self.petlv = self.transform:FindChild("@Grouppetui/@petblood/@petlv").gameObject;
		self.petname = self.transform:FindChild("@Grouppetui/@petblood/@petname").gameObject;
		self.petHeadportrait = self.transform:FindChild("@Grouppetui/@petblood/@petHeadportrait").gameObject;
		self.textpetstate = self.transform:FindChild("@Grouppetui/@petblood/@textpetstate").gameObject;
		self.progressbarui = self.transform:FindChild("@Grouppetui/@progressbarui").gameObject;
		self.timeprogressbar = self.transform:FindChild("@Grouppetui/@progressbarui/@timeprogressbar").gameObject;
		self.timeprogressbar = self.transform:FindChild("@Grouppetui/@progressbarui/@timeprogressbar/@timeprogressbar").gameObject;
		self.texttimeprogressbar = self.transform:FindChild("@Grouppetui/@progressbarui/@timeprogressbar/@texttimeprogressbar").gameObject;
		self.successprogressbar = self.transform:FindChild("@Grouppetui/@progressbarui/@successprogressbar").gameObject;
		self.successprogressbar = self.transform:FindChild("@Grouppetui/@progressbarui/@successprogressbar/@successprogressbar").gameObject;
		self.textsuccessprogressbar = self.transform:FindChild("@Grouppetui/@progressbarui/@successprogressbar/@textsuccessprogressbar").gameObject;
		self.textsuccessadd = self.transform:FindChild("@Grouppetui/@progressbarui/@successprogressbar/@textsuccessadd").gameObject;
		self.successrate = self.transform:FindChild("@Grouppetui/@progressbarui/@successrate").gameObject;
		self.success = self.transform:FindChild("@Grouppetui/@success").gameObject;
		self.failure = self.transform:FindChild("@Grouppetui/@failure").gameObject;
		self.iconCapturepet = self.transform:FindChild("@Grouppetui/@iconCapturepet").gameObject;
		self.FightGrouppet = self.transform:FindChild("@Grouppetui/@FightGrouppet").gameObject;
		self.Capturepetui = self.transform:FindChild("@Grouppetui/@FightGrouppet/@Capturepetui").gameObject;
		self.bgaperture = self.transform:FindChild("@Grouppetui/@FightGrouppet/@Capturepetui/@bgaperture").gameObject;
		self.Capturepetaperture = self.transform:FindChild("@Grouppetui/@FightGrouppet/@Capturepetui/@Capturepetaperture").gameObject;
		self.imgpetSkill3 = self.transform:FindChild("@Grouppetui/@FightGrouppet/btnpetSkill3/@imgpetSkill3").gameObject;
		self.bgcountdown3 = self.transform:FindChild("@Grouppetui/@FightGrouppet/btnpetSkill3/@bgcountdown3").gameObject;
		self.linecountdown3 = self.transform:FindChild("@Grouppetui/@FightGrouppet/btnpetSkill3/@linecountdown3").gameObject;
		self.imgpetSkill2 = self.transform:FindChild("@Grouppetui/@FightGrouppet/btnpetSkill2/@imgpetSkill2").gameObject;
		self.bgcountdown2 = self.transform:FindChild("@Grouppetui/@FightGrouppet/btnpetSkill2/@bgcountdown2").gameObject;
		self.linecountdown2 = self.transform:FindChild("@Grouppetui/@FightGrouppet/btnpetSkill2/@linecountdown2").gameObject;
		self.imgpetSkill1 = self.transform:FindChild("@Grouppetui/@FightGrouppet/btnpetSkill1/@imgpetSkill1").gameObject;
		self.bgcountdown1 = self.transform:FindChild("@Grouppetui/@FightGrouppet/btnpetSkill1/@bgcountdown1").gameObject;
		self.linecountdown1 = self.transform:FindChild("@Grouppetui/@FightGrouppet/btnpetSkill1/@linecountdown1").gameObject;
		self.imgpetSkill4 = self.transform:FindChild("@Grouppetui/@FightGrouppet/btnpetSkill4/@imgpetSkill4").gameObject;
		self.bgcountdown4 = self.transform:FindChild("@Grouppetui/@FightGrouppet/btnpetSkill4/@bgcountdown4").gameObject;
		self.linecountdown4 = self.transform:FindChild("@Grouppetui/@FightGrouppet/btnpetSkill4/@linecountdown4").gameObject;
		self.eff_UIGlow_common = self.transform:FindChild("@eff_UIGlow_common").gameObject;
	end
	return self;
end
Grouppetui = Grouppetui or CreateGrouppetui();
