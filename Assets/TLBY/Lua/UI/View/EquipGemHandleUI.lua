----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateEquipGemHandleUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.tabs = self.transform:FindChild("@tabs").gameObject;
		self.tab1 = self.transform:FindChild("@tabs/@tab1").gameObject;
		self.tab2 = self.transform:FindChild("@tabs/@tab2").gameObject;
		self.tabLight = self.transform:FindChild("@tabs/@tabLight").gameObject;
		self.tabText1 = self.transform:FindChild("@tabs/@tabText1").gameObject;
		self.tabText2 = self.transform:FindChild("@tabs/@tabText2").gameObject;
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.select = self.transform:FindChild("left/@select").gameObject;
		self.item = self.transform:FindChild("left/@item").gameObject;
		self.scrollView = self.transform:FindChild("left/@scrollView").gameObject;
		self.bgpaginright1 = self.transform:FindChild("@bgpaginright1").gameObject;
		self.composeEffect = self.transform:FindChild("@bgpaginright1/@composeEffect").gameObject;
		self.animIcon1 = self.transform:FindChild("@bgpaginright1/@composeEffect/@animIcon1").gameObject;
		self.animIcon2 = self.transform:FindChild("@bgpaginright1/@composeEffect/@animIcon2").gameObject;
		self.animIcon3 = self.transform:FindChild("@bgpaginright1/@composeEffect/@animIcon3").gameObject;
		self.animIcon4 = self.transform:FindChild("@bgpaginright1/@composeEffect/@animIcon4").gameObject;
		self.centerIcon = self.transform:FindChild("@bgpaginright1/@composeEffect/@centerIcon").gameObject;
		self.add3 = self.transform:FindChild("@bgpaginright1/@add3").gameObject;
		self.addIcon3 = self.transform:FindChild("@bgpaginright1/@add3/@addIcon3").gameObject;
		self.addNum3 = self.transform:FindChild("@bgpaginright1/@add3/@addIcon3/@addNum3").gameObject;
		self.add2 = self.transform:FindChild("@bgpaginright1/@add2").gameObject;
		self.addIcon2 = self.transform:FindChild("@bgpaginright1/@add2/@addIcon2").gameObject;
		self.addNum2 = self.transform:FindChild("@bgpaginright1/@add2/@addIcon2/@addNum2").gameObject;
		self.add1 = self.transform:FindChild("@bgpaginright1/@add1").gameObject;
		self.addIcon1 = self.transform:FindChild("@bgpaginright1/@add1/@addIcon1").gameObject;
		self.addNum1 = self.transform:FindChild("@bgpaginright1/@add1/@addIcon1/@addNum1").gameObject;
		self.add4 = self.transform:FindChild("@bgpaginright1/@add4").gameObject;
		self.addIcon4 = self.transform:FindChild("@bgpaginright1/@add4/@addIcon4").gameObject;
		self.addNum4 = self.transform:FindChild("@bgpaginright1/@add4/@addIcon4/@addNum4").gameObject;
		self.selectEffect = self.transform:FindChild("@bgpaginright1/@selectEffect").gameObject;
		self.note1 = self.transform:FindChild("@bgpaginright1/note/@note1").gameObject;
		self.note2 = self.transform:FindChild("@bgpaginright1/note/@note2").gameObject;
		self.btnCompose = self.transform:FindChild("@bgpaginright1/@btnCompose").gameObject;
		self.bgpaginright2 = self.transform:FindChild("@bgpaginright2").gameObject;
		self.btnPolish = self.transform:FindChild("@bgpaginright2/@btnPolish").gameObject;
		self.mainQuality = self.transform:FindChild("@bgpaginright2/mainIconBg/@mainQuality").gameObject;
		self.mainIcon = self.transform:FindChild("@bgpaginright2/mainIconBg/@mainIcon").gameObject;
		self.mainNum = self.transform:FindChild("@bgpaginright2/mainIconBg/@mainNum").gameObject;
		self.mainName = self.transform:FindChild("@bgpaginright2/@mainName").gameObject;
		self.materialQuality1 = self.transform:FindChild("@bgpaginright2/materialBg1/@materialQuality1").gameObject;
		self.materialIcon1 = self.transform:FindChild("@bgpaginright2/materialBg1/@materialIcon1").gameObject;
		self.materialName1 = self.transform:FindChild("@bgpaginright2/materialBg1/@materialName1").gameObject;
		self.materialDes1 = self.transform:FindChild("@bgpaginright2/materialBg1/@materialDes1").gameObject;
		self.materialNum1 = self.transform:FindChild("@bgpaginright2/materialBg1/@materialNum1").gameObject;
		self.materialQuality2 = self.transform:FindChild("@bgpaginright2/materialBg2/@materialQuality2").gameObject;
		self.materialIcon2 = self.transform:FindChild("@bgpaginright2/materialBg2/@materialIcon2").gameObject;
		self.materialName2 = self.transform:FindChild("@bgpaginright2/materialBg2/@materialName2").gameObject;
		self.materialDes2 = self.transform:FindChild("@bgpaginright2/materialBg2/@materialDes2").gameObject;
		self.materialNum2 = self.transform:FindChild("@bgpaginright2/materialBg2/@materialNum2").gameObject;
		self.useSpecial = self.transform:FindChild("@bgpaginright2/materialBg2/@useSpecial").gameObject;
		self.choosepropdown = self.transform:FindChild("@bgpaginright2/@choosepropdown").gameObject;
		self.effectSuccess = self.transform:FindChild("@bgpaginright2/@effectSuccess").gameObject;
		self.effectPolish = self.transform:FindChild("@bgpaginright2/@effectPolish").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
	end
	return self;
end
EquipGemHandleUI = EquipGemHandleUI or CreateEquipGemHandleUI();
