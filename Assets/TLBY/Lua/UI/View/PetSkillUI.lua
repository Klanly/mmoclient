----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePetSkillUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.textlevel1book = self.transform:FindChild("bgleft/bgWood frame/bglineCut/@textlevel1book").gameObject;
		self.textskillbooksmessage = self.transform:FindChild("bgleft/bgWood frame/bglineCut/@textskillbooksmessage").gameObject;
		self.textscore2 = self.transform:FindChild("bgleft/bgWood frame/bglineCut/@textscore2").gameObject;
		self.iconsilver2 = self.transform:FindChild("bgleft/bgWood frame/bglineCut/@iconsilver2").gameObject;
		self.SkillBooksScrollView = self.transform:FindChild("bgleft/bgWood frame/bglineCut/@SkillBooksScrollView").gameObject;
		self.SkillItemUI = self.transform:FindChild("bgleft/bgWood frame/bglineCut/@SkillBooksScrollView/ViewPort/content/@SkillItemUI").gameObject;
		self.btnupgrade = self.transform:FindChild("bgleft/@btnupgrade").gameObject;
		self.btnstudy = self.transform:FindChild("bgleft/@btnstudy").gameObject;
		self.iconSkill1 = self.transform:FindChild("bgleft/@iconSkill1").gameObject;
		self.iconDesign1 = self.transform:FindChild("bgleft/@iconSkill1/@iconDesign1").gameObject;
		self.iconLockDesign1 = self.transform:FindChild("bgleft/@iconSkill1/@iconLockDesign1").gameObject;
		self.iconAddDesign1 = self.transform:FindChild("bgleft/@iconSkill1/@iconAddDesign1").gameObject;
		self.selectIcon1 = self.transform:FindChild("bgleft/@iconSkill1/@selectIcon1").gameObject;
		self.skillNum1 = self.transform:FindChild("bgleft/@iconSkill1/@skillNum1").gameObject;
		self.iconSkill2 = self.transform:FindChild("bgleft/@iconSkill2").gameObject;
		self.iconDesign2 = self.transform:FindChild("bgleft/@iconSkill2/@iconDesign2").gameObject;
		self.iconLockDesign2 = self.transform:FindChild("bgleft/@iconSkill2/@iconLockDesign2").gameObject;
		self.iconAddDesign2 = self.transform:FindChild("bgleft/@iconSkill2/@iconAddDesign2").gameObject;
		self.selectIcon2 = self.transform:FindChild("bgleft/@iconSkill2/@selectIcon2").gameObject;
		self.skillNum2 = self.transform:FindChild("bgleft/@iconSkill2/@skillNum2").gameObject;
		self.iconSkill3 = self.transform:FindChild("bgleft/@iconSkill3").gameObject;
		self.iconDesign3 = self.transform:FindChild("bgleft/@iconSkill3/@iconDesign3").gameObject;
		self.iconLockDesign3 = self.transform:FindChild("bgleft/@iconSkill3/@iconLockDesign3").gameObject;
		self.iconAddDesign3 = self.transform:FindChild("bgleft/@iconSkill3/@iconAddDesign3").gameObject;
		self.selectIcon3 = self.transform:FindChild("bgleft/@iconSkill3/@selectIcon3").gameObject;
		self.skillNum3 = self.transform:FindChild("bgleft/@iconSkill3/@skillNum3").gameObject;
		self.iconSkill4 = self.transform:FindChild("bgleft/@iconSkill4").gameObject;
		self.iconDesign4 = self.transform:FindChild("bgleft/@iconSkill4/@iconDesign4").gameObject;
		self.iconLockDesign4 = self.transform:FindChild("bgleft/@iconSkill4/@iconLockDesign4").gameObject;
		self.iconAddDesign4 = self.transform:FindChild("bgleft/@iconSkill4/@iconAddDesign4").gameObject;
		self.selectIcon4 = self.transform:FindChild("bgleft/@iconSkill4/@selectIcon4").gameObject;
		self.skillNum4 = self.transform:FindChild("bgleft/@iconSkill4/@skillNum4").gameObject;
		self.iconSkill5 = self.transform:FindChild("bgleft/@iconSkill5").gameObject;
		self.iconDesign5 = self.transform:FindChild("bgleft/@iconSkill5/@iconDesign5").gameObject;
		self.iconLockDesign5 = self.transform:FindChild("bgleft/@iconSkill5/@iconLockDesign5").gameObject;
		self.iconAddDesign5 = self.transform:FindChild("bgleft/@iconSkill5/@iconAddDesign5").gameObject;
		self.selectIcon5 = self.transform:FindChild("bgleft/@iconSkill5/@selectIcon5").gameObject;
		self.skillNum5 = self.transform:FindChild("bgleft/@iconSkill5/@skillNum5").gameObject;
		self.iconSkill6 = self.transform:FindChild("bgleft/@iconSkill6").gameObject;
		self.iconDesign6 = self.transform:FindChild("bgleft/@iconSkill6/@iconDesign6").gameObject;
		self.iconLockDesign6 = self.transform:FindChild("bgleft/@iconSkill6/@iconLockDesign6").gameObject;
		self.iconAddDesign6 = self.transform:FindChild("bgleft/@iconSkill6/@iconAddDesign6").gameObject;
		self.selectIcon6 = self.transform:FindChild("bgleft/@iconSkill6/@selectIcon6").gameObject;
		self.skillNum6 = self.transform:FindChild("bgleft/@iconSkill6/@skillNum6").gameObject;
		self.iconSkill7 = self.transform:FindChild("bgleft/@iconSkill7").gameObject;
		self.iconDesign7 = self.transform:FindChild("bgleft/@iconSkill7/@iconDesign7").gameObject;
		self.iconLockDesign7 = self.transform:FindChild("bgleft/@iconSkill7/@iconLockDesign7").gameObject;
		self.iconAddDesign7 = self.transform:FindChild("bgleft/@iconSkill7/@iconAddDesign7").gameObject;
		self.selectIcon7 = self.transform:FindChild("bgleft/@iconSkill7/@selectIcon7").gameObject;
		self.skillNum7 = self.transform:FindChild("bgleft/@iconSkill7/@skillNum7").gameObject;
		self.iconSkill8 = self.transform:FindChild("bgleft/@iconSkill8").gameObject;
		self.iconDesign8 = self.transform:FindChild("bgleft/@iconSkill8/@iconDesign8").gameObject;
		self.iconLockDesign8 = self.transform:FindChild("bgleft/@iconSkill8/@iconLockDesign8").gameObject;
		self.iconAddDesign8 = self.transform:FindChild("bgleft/@iconSkill8/@iconAddDesign8").gameObject;
		self.selectIcon8 = self.transform:FindChild("bgleft/@iconSkill8/@selectIcon8").gameObject;
		self.skillNum8 = self.transform:FindChild("bgleft/@iconSkill8/@skillNum8").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
	end
	return self;
end
PetSkillUI = PetSkillUI or CreatePetSkillUI();
