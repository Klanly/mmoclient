----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"
require "Logic/Bag/QualityConst"
require "UI/TextAnchor"

local itemtable = require "Logic/Scheme/common_item"
local texttable = require "Logic/Scheme/common_char_chinese"
local localization = require "Common/basic/Localization"

local itemconfigs = itemtable.Item

local function CreateEquipmentSmeltingItemUI()
	local self = CreateViewBase();
	self.pos = 0
	self.Awake = function()
		self.chooseequipmentdown = self.transform:FindChild("@chooseequipmentdown").gameObject;
		self.textdeputyequipmentname1 = self.transform:FindChild("@textdeputyequipmentname1").gameObject;
		self.chooseequipmentup = self.transform:FindChild("@chooseequipmentup").gameObject;
		self.bgdeputyequipment1 = self.transform:FindChild("@bgdeputyequipment1").gameObject;
		self.icondeputyequipment1 = self.transform:FindChild("@icondeputyequipment1").gameObject;
		self.Quality = self.transform:FindChild("@Quality").gameObject;
		self.Init()
	end

	local function OnClick()
		if UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).isLoaded then
			UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).isSelectEquipment = false
			UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).currentEquipmentPos = self.pos
			UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).currentReplaceProperty = 0
			UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).UpdateView()
		end
	end

	self.Init = function()
		self.textName = self.textdeputyequipmentname1:GetComponent("TextMeshProUGUI")
		self.imgEquipmentIcon = self.icondeputyequipment1:GetComponent("Image")
		self.imgQuality = self.Quality:GetComponent("Image")
		ClickEventListener.Get(self.icondeputyequipment1).onClick = OnClick
	end

	--装备在背包中的位置
	self.SetData = function(indata)
		self.pos = indata.pos
		self.UpdateView()
	end

	self.UpdateView = function()
		local itemdata = BagManager.items[self.pos]
		if itemdata == nil then
			return
		end

		local itemconfig = itemconfigs[itemdata.id]
		if itemconfig == nil then
			return
		end

		self.textName.text = localization.GetItemName(itemdata.id)
		self.textName.color = QualityConst.GetQualityColor2(itemconfig.Quality)
		self.imgEquipmentIcon.overrideSprite = ResourceManager.LoadSprite("ItemIcon/"..itemconfig.Icon)
		self.imgQuality.overrideSprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(itemconfig.Quality))
	end

	return self;
end
return CreateEquipmentSmeltingItemUI()
