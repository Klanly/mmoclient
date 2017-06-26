----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"
require "Logic/Entity/Attribute/AttributeConst"
require "Logic/Bag/QualityConst"

local texttable = require "Logic/Scheme/common_char_chinese"
local uitext = texttable.UIText

local function CreateEquipSmeltingPropertyUI()
	local self = CreateViewBase();
	self.data = {}

	self.Awake = function()
		self.chooseequipmentbown = self.transform:FindChild("@chooseequipmentbown").gameObject;
		self.textequipmentattribute = self.transform:FindChild("@textequipmentattribute").gameObject;
		self.bgequipmenthook = self.transform:FindChild("@bgequipmenthook").gameObject;
		self.bgequipmentattribute = self.transform:FindChild("@bgequipmentattribute").gameObject;
		self.bgequipmentattribute_1 = self.transform:FindChild("@bgequipmentattribute_1").gameObject;
		self.Init()
	end

	local function OnClick()
		if self.data.pos == self.data.select then
			return
		end

		if self.data.sameProperty ~= 0 and  self.data.sameProperty ~= self.data.pos then
			UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
				ctrl.UpdateMsg(uitext[1116007].NR)
			end)
			return
		end

		if UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).isLoaded then
			if UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).isSelectEquipment then
				UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
					ctrl.UpdateMsg(uitext[1116011].NR)
				end)
				return
			end
			if UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).currentReplaceProperty == 0 then
				UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
					ctrl.UpdateMsg(uitext[1116010].NR)
				end)
				return
			end
			UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).SetProperty(self.data.pos)
		end
	end

	self.Init = function()
		self.textAttribute = self.textequipmentattribute:GetComponent("TextMeshProUGUI")
		ClickEventListener.Get(self.bgequipmentattribute).onClick = OnClick
	end

	--indata
	--indata.data 洗练属性值，与服务端推送的数据一致，参见BagManager说明
	self.SetData = function(indata)
		self.data = indata
		self.UpdateView()
	end

	self.UpdateView = function()
		if self.data == nil then
			return
		end
		if self.data.data == nil then
			self.textAttribute.text = uitext[1116006].NR
			self.textAttribute.color = QualityConst.GetQualityColor2(QUALITY.QUALITY_GREEN)
		else
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
		end
		if self.data.pos == self.data.select then
			self.bgequipmenthook:SetActive(true)
			self.chooseequipmentbown:SetActive(true)
		else
			self.bgequipmenthook:SetActive(false)
			self.chooseequipmentbown:SetActive(false)
		end
		if self.data.sameProperty == 0 or self.data.sameProperty == self.data.pos then
			self.bgequipmentattribute_1:SetActive(true)
		else
			self.bgequipmentattribute_1:SetActive(false)
		end
	end

	return self;
end
return CreateEquipSmeltingPropertyUI()
