----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePetMergeEatUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnMainPet = self.transform:FindChild("main/@btnMainPet").gameObject;
		self.btnVicePet = self.transform:FindChild("main/@btnVicePet").gameObject;
		self.vicePart = self.transform:FindChild("main/@vicePart").gameObject;
		self.vicePetStar = self.transform:FindChild("main/@vicePart/@vicePetStar").gameObject;
		self.textViceName = self.transform:FindChild("main/@vicePart/@textViceName").gameObject;
		self.viceNeedStr = self.transform:FindChild("main/@viceNeedStr").gameObject;
		self.btnAdd = self.transform:FindChild("main/@btnAdd").gameObject;
		self.eatPart = self.transform:FindChild("main/@eatPart").gameObject;
		self.btnEat = self.transform:FindChild("main/@eatPart/@btnEat").gameObject;
		self.mergePart = self.transform:FindChild("main/@mergePart").gameObject;
		self.btnMerge = self.transform:FindChild("main/@mergePart/@btnMerge").gameObject;
		self.btnAttribute = self.transform:FindChild("main/@btnAttribute").gameObject;
		self.textMainName = self.transform:FindChild("main/@textMainName").gameObject;
		self.mainPetStar = self.transform:FindChild("main/@mainPetStar").gameObject;
		self.mainPetModel = self.transform:FindChild("main/mainPetModel/@mainPetModel").gameObject;
		self.vicePetModel = self.transform:FindChild("main/vicePetModel/@vicePetModel").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
	end
	return self;
end
PetMergeEatUI = PetMergeEatUI or CreatePetMergeEatUI();
