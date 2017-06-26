----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"
require "Logic/Entity/Attribute/AttributeConst"
require "Logic/Bag/QualityConst"

local texttable = require "Logic/Scheme/common_char_chinese"
local uitext = texttable.UIText

local function CreateEquipSmeltingReplacePropertyUI()
	local self = CreateViewBase();
	self.data = {}

	self.Awake = function()
		self.textequipmentattribute = self.transform:FindChild("@textequipmentattribute").gameObject;
		self.bgequipmentattribut = self.transform:FindChild("@bgequipmentattribut").gameObject;
		self.imgequipmenthook = self.transform:FindChild("@imgequipmenthook").gameObject;
		self.bgequipmentattribut_1 = self.transform:FindChild("@bgequipmentattribut_1").gameObject;
		self.Init()
	end

	local function OnClick()
		if self.data.same then
			UIManager.PushView(ViewAssets.PromptUI)
			UIManager.GetCtrl(ViewAssets.PromptUI).UpdateMsg(uitext[1116008].NR)
			return
		end

		if self.data.pos == self.data.select then
			return
		end

		if UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).isLoaded then
			UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).SetReplaceProperty(self.data.pos)
		end
	end

	self.Init = function()
		self.textAttribute = self.textequipmentattribute:GetComponent("TextMeshProUGUI")
		ClickEventListener.Get(self.bgequipmentattribut).onClick = OnClick
	end

	--indata
	--indata.data 洗练属性值，与服务端推送的数据一致，参见BagManager说明
	--indata.pos 第几条属性
	--indata.select 选中第几条属性
	self.SetData = function(indata)
		self.data = indata
		self.UpdateView()
	end

	self.UpdateView = function()
		if self.data == nil then
			return
		end
		if self.data.data[4] == 1 then
			self.textAttribute.text = AttributeConst.GetAttributeNameByIndex(self.data.data[1]).."  +"..math.floor(self.data.data[2]/100).."%"
		else
			self.textAttribute.text = AttributeConst.GetAttributeNameByIndex(self.data.data[1]).."  +"..self.data.data[2]
		end
		if self.data.data[3] then
			self.textAttribute.color = QualityConst.GetQualityColor2(QUALITY.QUALITY_GOLDEN)
		else
			self.textAttribute.color = QualityConst.GetQualityColor2(QUALITY.QUALITY_GREEN)
		end
		if self.data.select == self.data.pos then
			self.imgequipmenthook:SetActive(true)
		else
			self.imgequipmenthook:SetActive(false)
		end
		if self.data.same then
			self.bgequipmentattribut_1:SetActive(false)
		else
			self.bgequipmentattribut_1:SetActive(true)
		end
	end

	return self;
end
return CreateEquipSmeltingReplacePropertyUI()
