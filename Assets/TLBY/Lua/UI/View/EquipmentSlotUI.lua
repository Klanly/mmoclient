----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"
require "Logic/Bag/QualityConst"

local const = require "Common/constant"
local itemtable = require "Logic/Scheme/common_item"
local texttable = require "Logic/Scheme/common_char_chinese"
local localization = require "Common/basic/Localization"

local itemconfigs = itemtable.Item
local uitext = texttable.UIText
local equip_type_to_name = const.equip_type_to_name

local function CreateEquipmentSlotUI()
	local self = CreateViewBase();
	--data={slot,item}
	local slot = ""
	local smeltingPos = 0
	self.Awake = function()
		self.bgchooseStrengthenstone = self.transform:FindChild("@bgchooseStrengthenstone").gameObject;
		self.textStrengthenstonename = self.transform:FindChild("@textStrengthenstonename").gameObject;
		self.textStrengthenstonelv = self.transform:FindChild("@textStrengthenstonelv").gameObject;
		self.bgiconStrengthenstone = self.transform:FindChild("@bgiconStrengthenstone").gameObject;
		self.Quality = self.transform:FindChild("@Quality").gameObject;
		self.iconStrengthenstone = self.transform:FindChild("@iconStrengthenstone").gameObject;
		self.chooseStrengthenstonedown = self.transform:FindChild("@chooseStrengthenstonedown").gameObject;
		self.bgchoose = self.transform:FindChild("@bgchoose").gameObject;
		self.using = self.transform:FindChild("@using").gameObject;
		self.Init()
	end

	local function onSelectHandler()
		if BagManager.currentEquipSlot ~= slot or BagManager.currentSmeltingPos ~= smeltingPos then
			BagManager.currentEquipSlot = slot
			BagManager.currentSmeltingPos = smeltingPos
			if UIManager.GetCtrl(ViewAssets.EquipmentUI).isLoaded then
				if UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).isLoaded then
					UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).isSelectEquipment = true
					UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).currentEquipmentPos = 0
				end
				UIManager.GetCtrl(ViewAssets.EquipmentUI).UpdateView()
			end
		end
	end

	self.Init = function()
		self.textStrengthen = self.textStrengthenstonelv:GetComponent("TextMeshProUGUI")
		self.textStrengthen.color = QualityConst.GetQualityColor2(QUALITY.QUALITY_GREEN)
		self.textStrengthen.fontSize = 26
		--UIUtil.AddTextOutline(self.textStrengthenstonelv,QualityConst.GetDarkOutlineColor())
		self.textName = self.textStrengthenstonename:GetComponent("TextMeshProUGUI")
		self.textName.fontSize = 32
		--UIUtil.AddTextOutline(self.textStrengthenstonename,QualityConst.GetDarkOutlineColor())

		self.imgQuality = self.Quality:GetComponent("Image")
		self.imgIcon = self.iconStrengthenstone:GetComponent("Image")
		ClickEventListener.Get(self.bgchooseStrengthenstone).onClick = onSelectHandler
	end

	--inslot ��λ���������
	--id װ��id
	--tab��ǰ��ҳ
	--pos inslotΪ��λʱ����,inslotΪ����ʱ�������ڱ����е�λ��
	self.SetData = function(inslot,id,tab,pos)
		if tab ~= EquipmentUITab.SMELTING and inslot == "bag" then
			return
		end

		slot = inslot
		smeltingPos = pos
		local itemconfig = itemconfigs[id]
		if itemconfig == nil then
			return
		end
		self.textName.text = localization.GetItemName(id)
		self.textName.color = QualityConst.GetQualityColor2(itemconfig.Quality)
		if tab == EquipmentUITab.STRENGTHEN then
			local stage = 1
			local level = 0
			local strengthen = BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]]
			if strengthen then
				stage = strengthen.stage
				level = strengthen.level
			end
			if stage == 1 then
				self.textStrengthen.text = uitext[1114076].NR.."+"..level
			elseif stage == 2 then
				self.textStrengthen.text = uitext[1114077].NR.."+"..level
			elseif stage == 3 then
				self.textStrengthen.text = uitext[1114078].NR.."+"..level
			elseif stage == 4 then
				self.textStrengthen.text = uitext[1114079].NR.."+"..level
			else
				self.textStrengthen.text = uitext[1114080].NR.."+"..level
			end
		elseif tab == EquipmentUITab.UPGRADESTAR then
			local star = 0
			local equipstar = BagManager.equipment_star[equip_type_to_name[itemconfig.Type]]
			if equipstar then
				star = equipstar.star
			end
			self.textStrengthen.text = string.format(uitext[1125004].NR,star)
		elseif tab == EquipmentUITab.SMELTING then
			local rare_count = 0
			local additional_prop = nil
			if slot == "bag" then
				additional_prop = BagManager.items[pos].additional_prop
			else
				additional_prop = BagManager.equipments[equip_type_to_name[itemconfig.Type]].additional_prop
			end

			for i,v in pairs(additional_prop) do
				if v[3] then
					rare_count = rare_count + 1
				end
			end
			if rare_count < 5 then
				self.textStrengthen.text = ""
			elseif rare_count == 5 then
				self.textStrengthen.text = uitext[1114044].NR
			elseif rare_count == 6 then
				self.textStrengthen.text = uitext[1114045].NR
			elseif rare_count == 7 then
				self.textStrengthen.text = uitext[1114046].NR
			elseif rare_count == 8 then
				self.textStrengthen.text = uitext[1114047].NR
			else
				self.textStrengthen.text = uitext[1114048].NR
			end
		else
			self.textStrengthen.text = ""
		end

		self.imgQuality.overrideSprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(itemconfig.Quality))
		self.imgIcon.overrideSprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",itemconfig.Icon))
		if BagManager.currentEquipSlot == slot then
			if slot == "bag" then
				if BagManager.currentSmeltingPos == smeltingPos then
					self.chooseStrengthenstonedown:SetActive(true)
					self.bgchoose:SetActive(true)
				else
					self.chooseStrengthenstonedown:SetActive(false)
					self.bgchoose:SetActive(false)
				end
			else
				self.chooseStrengthenstonedown:SetActive(true)
				self.bgchoose:SetActive(true)
			end
		else
			self.chooseStrengthenstonedown:SetActive(false)
			self.bgchoose:SetActive(false)
		end
		if slot == "bag" then
			self.using:SetActive(false)
		else
			self.using:SetActive(true)
		end
	end

	return self;
end

return CreateEquipmentSlotUI();
