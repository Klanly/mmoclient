----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePetAttributeUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("bg/@btnClose").gameObject;
		self.petSort = self.transform:FindChild("sort/@petSort").gameObject;
		self.petScore = self.transform:FindChild("score/@petScore").gameObject;
		self.rareValue = self.transform:FindChild("rare/@rareValue").gameObject;
		self.starNum = self.transform:FindChild("star/@starNum").gameObject;
		self.element = self.transform:FindChild("element/@element").gameObject;
		self.level = self.transform:FindChild("level/@level").gameObject;
		self.mergeNum = self.transform:FindChild("mergeNum/@mergeNum").gameObject;
		self.eatNum = self.transform:FindChild("eatNum/@eatNum").gameObject;
		self.attributeScrollView = self.transform:FindChild("@attributeScrollView").gameObject;
		self.attributeItem = self.transform:FindChild("@attributeScrollView/Viewport/content/@attributeItem").gameObject;
		self.propertyScrollView = self.transform:FindChild("@propertyScrollView").gameObject;
	end
	return self;
end
PetAttributeUI = PetAttributeUI or CreatePetAttributeUI();
