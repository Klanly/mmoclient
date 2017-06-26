----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateArenaPetSetting()
	local self = CreateViewBase();
	self.Awake = function()
		self.petlistgroupsv = self.transform:FindChild("petgroup/@petlistgroupsv").gameObject;
		self.textpetslist = self.transform:FindChild("petgroup/@petlistgroupsv/@textpetslist").gameObject;
		self.btnArrow = self.transform:FindChild("petgroup/@petlistgroupsv/@btnArrow").gameObject;
		self.optionPetItem = self.transform:FindChild("petgroup/@petlistgroupsv/Viewport/Content/@optionPetItem").gameObject;
		self.textpetname = self.transform:FindChild("petgroup/@petlistgroupsv/Viewport/Content/@optionPetItem/@textpetname").gameObject;
		self.textStarlv = self.transform:FindChild("petgroup/@petlistgroupsv/Viewport/Content/@optionPetItem/@textStarlv").gameObject;
		self.textpetstitle = self.transform:FindChild("petgroup/selectPetGroup/@textpetstitle").gameObject;
		self.selectpetlistsv = self.transform:FindChild("petgroup/selectPetGroup/@selectpetlistsv").gameObject;
		self.selectPetItem1 = self.transform:FindChild("petgroup/selectPetGroup/@selectpetlistsv/Viewport/Content/@selectPetItem1").gameObject;
		self.textpetname = self.transform:FindChild("petgroup/selectPetGroup/@selectpetlistsv/Viewport/Content/@selectPetItem1/@textpetname").gameObject;
		self.textStarlv = self.transform:FindChild("petgroup/selectPetGroup/@selectpetlistsv/Viewport/Content/@selectPetItem1/@textStarlv").gameObject;
		self.textuesedskilltitle = self.transform:FindChild("skillsgroup/@textuesedskilltitle").gameObject;
		self.skillItem = self.transform:FindChild("skillsgroup/skillssv/Viewport/Content/@skillItem").gameObject;
		self.skillimg1 = self.transform:FindChild("skillsgroup/skillssv/Viewport/Content/@skillItem/@skillimg1").gameObject;
		self.textSkillname1 = self.transform:FindChild("skillsgroup/skillssv/Viewport/Content/@skillItem/@textSkillname1").gameObject;
		self.btnclose2 = self.transform:FindChild("btngroup/@btnclose2").gameObject;
		self.btnok = self.transform:FindChild("btngroup/@btnok").gameObject;
		self.textbtnok = self.transform:FindChild("btngroup/@textbtnok").gameObject;
		self.skillpartgroup = self.transform:FindChild("@skillpartgroup").gameObject;
		self.textframeskilltitle = self.transform:FindChild("@skillpartgroup/@textframeskilltitle").gameObject;
		self.skillpartitem = self.transform:FindChild("@skillpartgroup/partlistsv/Viewport/Content/@skillpartitem").gameObject;
		self.partimgbg = self.transform:FindChild("@skillpartgroup/partlistsv/Viewport/Content/@skillpartitem/@partimgbg").gameObject;
		self.partname1 = self.transform:FindChild("@skillpartgroup/partlistsv/Viewport/Content/@skillpartitem/@partname1").gameObject;
		self.partimg1 = self.transform:FindChild("@skillpartgroup/partlistsv/Viewport/Content/@skillpartitem/@partimg1").gameObject;
	end
	return self;
end
ArenaPetSetting = ArenaPetSetting or CreateArenaPetSetting();
