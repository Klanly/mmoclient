--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/26 0026
-- Time: 17:32
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"
require "Logic/Bag/ItemType"
require "Logic/Entity/Attribute/VocationConst"
require "Logic/Entity/Attribute/AttributeConst"
require "Logic/Bag/QualityConst"
require "UI/TextAnchor"
require "math"
require "UI/UIGrayMaterial"
local equipment_star = require "Logic/Scheme/equipment_star"
local equipment_strengthen = require "Logic/Scheme/equipment_strengthen"

local const = require "Common/constant"
local itemtable = require "Logic/Scheme/common_item"
local texttable = require "Logic/Scheme/common_char_chinese"
local equiptable = require "Logic/Scheme/equipment_base"
local localization = require "Common/basic/Localization"
local common_parameter_formula = require "Logic/Scheme/common_parameter_formula"
local equipment_gem_table = require "Logic/Scheme/equipment_jewel"
local equipment_attributes = require("Logic/Scheme/equipment_base").Attribute
local equipment_attribute_value_type = const.EQUIPMENT_ATTRIBUTE_VALUE_TYPE
local equipment_strengthen_config = require "Logic/configs/equipment_strengthen_config"
--装备评分。a=生命值，b=内力，c=攻击(物攻+法功)，d=防御(物防+法防)，e=对抗属性(命中，闪避等之和)。f=元素攻击，g=元素防御。
local CalculateEquipScore = loadstring("return function (a, b,c,d,e,f,g) return "..common_parameter_formula.Formula[13].Formula.." end")()

local uitext = texttable.UIText
local equip_type_to_name = const.equip_type_to_name
local PROPERTY_NAME_TO_INDEX = const.PROPERTY_NAME_TO_INDEX
local PROPERTY_INDEX_TO_NAME = const.PROPERTY_INDEX_TO_NAME

--属性汇总
local equipment_base_attibutes = {}
for _,attribute in pairs(equipment_attributes) do
    equipment_base_attibutes[attribute.ID] = attribute
end

--宝石数值（属性等）配置
local gem_value_configs = {}
for _,v in pairs(equipment_gem_table.GemValue) do
    if gem_value_configs[v.GemID] == nil then
        gem_value_configs[v.GemID] = {}
    end
    gem_value_configs[v.GemID][v.Level] = v
end

--宝石类型配置
local gem_type_configs = {}
local gem_type_normal = {}
local gem_type_special = {}
--混沌石鉴定结果权重
local chaos_stone_identify_results = {}
local chaos_stone_identify_results_weight = {}
local tmp_chaos_stone_identify_results_weight = {}
for _,v in pairs(equipment_gem_table.GemType) do
    gem_type_configs[v.GemID] = v
end

--宝石等级配置表
local gem_level_configs = {}
for _,v in pairs(equipment_gem_table.GemLevel) do
    gem_level_configs[v.Level] = v
end

local gem_shape_configs = equipment_gem_table.GemShape

local gem_configs = {}
--物品id对应宝石数据
local item_gem_configs = {}
local item_scheme_params = {}
for _,v in pairs(itemtable.Item) do
    if v.Type == const.TYPE_GEM then
        item_scheme_params = string.split(v.Para1,"|")
        if #item_scheme_params == 2 then
            local gid = tonumber(item_scheme_params[1])
            local glevel = tonumber(item_scheme_params[2])
            local gshape = tonumber(v.Para2)
            if gid ~= nil and glevel ~= nil and gshape ~= nil then
                local gid_cfg = gem_type_configs[gid]
                local glevel_cfg = gem_level_configs[glevel]
                local gshape_cfg = gem_shape_configs[gshape]
                if gid_cfg ~= nil and glevel_cfg ~= nil and gshape_cfg ~= nil then
                    if gem_configs[gid] == nil then
                        gem_configs[gid] = {}
                    end
                    if gem_configs[gid][glevel] == nil then
                        gem_configs[gid][glevel] = {}
                    end
                    gem_configs[gid][glevel][gshape] = v.ID
                    item_gem_configs[v.ID] = {}
                    item_gem_configs[v.ID].gem_id = gid
                    item_gem_configs[v.ID].gem_level = glevel
                    item_gem_configs[v.ID].gem_shape = gshape
                    item_gem_configs[v.ID].attribute_index = gid_cfg.AttriID
--                    if equipment_base_attibutes[gid_cfg.AttriID] ~= nil then
--                        item_gem_configs[v.ID].attribute_index = equipment_base_attibutes[gid_cfg.AttriID].LogicID
--                    end

                    item_gem_configs[v.ID].attribute_value_type = equipment_attribute_value_type.normal
--                    if equipment_base_attibutes[gid_cfg.AttriID] ~= nil then
--                        item_gem_configs[v.ID].attribute_value_type = equipment_base_attibutes[gid_cfg.AttriID].ValueType
--                    end
                    item_gem_configs[v.ID].attribute_value = 0
                    if gem_value_configs[gid] ~= nil and gem_value_configs[gid][glevel] ~= nil then
                        item_gem_configs[v.ID].attribute_value = gem_value_configs[gid][glevel].Num
                    end
                end
            end
        end
    end
end

local function GetEquipScore(itemdata)
	local score = 0
	if itemdata == nil then
		return score
	end
    local single_addition = {}
	local percent_addition = {}
	local strengthen_additional = {} --强化加成

	--计算基础属性加成
	local base_prop = itemdata.base_prop
	if base_prop ~= nil then
		for j, p in pairs(base_prop) do
			--基础属性
			if single_addition[j] ~= nil then
				single_addition[j] = single_addition[j] + p
			else
				single_addition[j] = p
			end
		end
	end

	--计算洗练属性加成
	local additional_prop = itemdata.additional_prop
	if additional_prop ~= nil then
		--洗练属性结构(1 属性索引，2 属性值，3是否稀有，4属性值类型)
		for j, p in pairs(additional_prop) do
			if p[4] == 2 then       --value_type为2的是正常属性加成
				if single_addition[p[1]] ~= nil then
					single_addition[p[1]] = single_addition[p[1]] + p[2]
				else
					single_addition[p[1]] = p[2]
				end
			elseif p[4] ==1 then        --value_type为1的是百分比属性加成
				if percent_addition[p[1]] ~= nil then
					percent_addition[p[1]] = percent_addition[p[1]] + p[2]
				else
					percent_addition[p[1]] = p[2]
				end
			end
		end
	end

	--洗练属性中万分比加成
	for j, p in pairs(percent_addition) do
		local s_value = single_addition[j]
		if s_value ~= nil then
			single_addition[j] = s_value + math.floor(s_value * p / 10000)
		end
	end

	for j,p in pairs(strengthen_additional) do
		if single_addition[j] == nil then
			single_addition[j] = p
		else
			single_addition[j] = single_addition[j] + p
		end
	end

	local hp = 0
	local mp = 0
	local attack = 0
	local defence = 0
	local fight_property = 0
	local element_attack = 0
	local element_defence = 0
	for property,value in pairs(single_addition) do
		if property == PROPERTY_NAME_TO_INDEX.hp_max then
			hp = hp + value
		end
		if property == PROPERTY_NAME_TO_INDEX.mp_max then
			mp = mp + value
		end
		if property == PROPERTY_NAME_TO_INDEX.physic_attack or property == PROPERTY_NAME_TO_INDEX.magic_attack then
			attack = attack + value
		end
		if property == PROPERTY_NAME_TO_INDEX.physic_defence or property == PROPERTY_NAME_TO_INDEX.magic_defence then
			defence = defence + value
		end
		if property >= PROPERTY_NAME_TO_INDEX.hit and property <= PROPERTY_NAME_TO_INDEX.guardian then
			fight_property = fight_property + value
		end
		if property >= PROPERTY_NAME_TO_INDEX.gold_attack and property <= PROPERTY_NAME_TO_INDEX.dark_attack then
			element_attack = element_attack + value
		end
		if property >= PROPERTY_NAME_TO_INDEX.gold_defence and property <= PROPERTY_NAME_TO_INDEX.dark_defence then
			element_defence = element_defence + value
		end
	end
	score = CalculateEquipScore(hp,mp,attack,defence,fight_property,element_attack,element_defence)
	return score
end

function CreateEquipTipsUICtrlBase()
    local self = CreateCtrlBase()
    self.itemdata = nil
    self.layer = LayerGroup.popCanvas
    local function Close()
		UIManager.UnloadView(ViewAssets.EquipTipsUI)
		UIManager.UnloadView(ViewAssets.CompareEquipTipsUI)
	end

    local function OnUseBtnClick()
		if BagManager.lock == true then
            UIManager.ShowNotice(texttable.UIText[1101056].NR)
            return
        end
        if not self.from == ItemTipsFromType.BAG or not self.itemdata.pos or not ItemType.IsEquipById(self.itemdata.item_data.id) then
            return
        end
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_LOAD_EQUIPMENT, {item_pos=self.itemdata.pos})
        Close()
    end

    local function OnEnhanceBtnClick()
		if BagManager.lock == true then
            UIManager.ShowNotice(texttable.UIText[1101056].NR)
            return
        end
        if self.itemdata.from ~= ItemTipsFromType.BAG and self.itemdata.from ~= ItemTipsFromType.PLAYER then
            return
        end

		local itemdata = self.itemdata.item_data
		local itemconfig = itemtable.Item[itemdata.id]
		if itemconfig then
			BagManager.currentEquipSlot = equip_type_to_name[itemconfig.Type]
			if self.itemdata.from == ItemTipsFromType.BAG then
				if not BagManager.IsSmeltingEquipmentByTypeAndPosition(itemconfig.Type,self.itemdata.pos) then
					UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
						ctrl.UpdateMsg(uitext[1116009].NR)
					end)        			
					return
				end
				BagManager.currentEquipTab = EquipmentUITab.SMELTING
				BagManager.currentEquipmentPos = self.itemdata.pos
			else
				BagManager.currentEquipTab = EquipmentUITab.STRENGTHEN
			end
			UIManager.PushView(ViewAssets.EquipmentUI, function(ctrl)
				ctrl.SetContentPosition()
			end)
		end
        Close()
    end

	local function OnLoadEquipmentReply(data)
		if data.result == 0 then
			BagManager.dressing = true
		end
	end

    local function OnCloseBtnClick()
        Close()
    end

    self.onLoad = function(callback)
		--装备按钮
		self.textUseBtn = self.view.textbtn1:GetComponent("TextMeshProUGUI")
		self.textUseBtn.text = uitext[1114083].NR
		--UIUtil.SetTextAlignment(self.textUseBtn,TextAnchor.MiddleCenter)
		--UIUtil.AddTextOutline(self.view.textbtn1,Color.New(8/255,96/255,80/255))
		--self.textUseBtn.fontSize = 32
		self.imgUseBtn = self.view.btnimage1:GetComponent("Image")
		--UIUtil.AddButtonEffect(self.view.btnimage1,nil,nil)
		--锻造按钮
		self.textSmithingBtn = self.view.textbtn2:GetComponent("TextMeshProUGUI")
		self.textSmithingBtn.text = uitext[1114057].NR
		--UIUtil.SetTextAlignment(self.textSmithingBtn,TextAnchor.MiddleCenter)
		--UIUtil.AddTextOutline(self.view.textbtn2,Color.New(8/255,96/255,80/255))
		--self.textSmithingBtn.fontSize = 32
		self.imgSmithingBtn = self.view.btnimage2:GetComponent("Image")
		--UIUtil.AddButtonEffect(self.view.btnimage2,nil,nil)
		--装备名字
		self.textName = self.view.texttitle:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.textName,TextAnchor.MiddleCenter)
		--UIUtil.AddTextOutline(self.view.texttitle,Color.New(242/255,179/255,121/255))
		--self.textName.fontSize = 40
		--装备部位
		self.textPart = self.view.textweapons:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.textPart,TextAnchor.MiddleLeft)
		--self.textPart.fontSize = 28
		--装备职业
		self.textVocation = self.view.textvocation:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.textVocation,TextAnchor.MiddleLeft)
		--self.textVocation.fontSize = 28
		--使用等级
		self.textLevel = self.view.textlevel:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.textLevel,TextAnchor.MiddleLeft)
		--self.textLevel.fontSize = 28
		--绑定状态
		self.textState = self.view.textstate:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.textState,TextAnchor.MiddleLeft)
		--self.textState.fontSize = 28
		--装备图标
		self.imgEquipIcon = self.view.equipment:GetComponent("Image")
		self.bgicon = self.view.bgicon:GetComponent("Image")
		--星星
		self.starTransform = self.view.star:GetComponent("RectTransform")
		self.stars = {}
		self.stars[1] = self.view.star1
		self.stars[2] = self.view.star2
		self.stars[3] = self.view.star3
		self.stars[4] = self.view.star4
		self.stars[5] = self.view.star5
		self.stars[6] = self.view.star6
		self.stars[7] = self.view.star7
		self.stars[8] = self.view.star8
		self.stars[9] = self.view.star9
		--装备评分
		self.textScore = self.view.textEquipmentscore:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.textScore,TextAnchor.MiddleCenter)
		--UIUtil.AddTextOutline(self.view.textEquipmentscore,Color.New(242/255,179/255,121/255))
		--self.textScore.fontSize = 40
		self.textScoreTransform = self.view.textEquipmentscore:GetComponent("RectTransform")
		--基础属性
		--底图
		self.bgBasicTransform = self.view.bgbasisattribute:GetComponent("RectTransform")
		--标签
		self.textBasicLabel = self.view.textbasisattributetitle:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.textBasicLabel,TextAnchor.MiddleLeft)
		--UIUtil.AddTextOutline(self.view.textbasisattributetitle,Color.New(242/255,179/255,121/255))
		--self.textBasicLabel.fontSize = 35
		self.textBasicLabelTransform = self.view.textbasisattributetitle:GetComponent("RectTransform")
		self.textBasicLabel.text = uitext[1114035].NR
		--属性1
		self.basicAttributes = {}
		self.basicAttributes[1] = {}
		self.basicAttributes[1].obj = self.view.textbasisattribute1
		self.basicAttributes[1].transform = self.view.textbasisattribute1:GetComponent("RectTransform")
		self.basicAttributes[1].text = self.view.textbasisattribute1:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.basicAttributes[1].text,TextAnchor.MiddleLeft)
		--self.basicAttributes[1].text.fontSize = 28
		--属性2
		self.basicAttributes[2] = {}
		self.basicAttributes[2].obj = self.view.textbasisattribute2
		self.basicAttributes[2].transform = self.view.textbasisattribute2:GetComponent("RectTransform")
		self.basicAttributes[2].text = self.view.textbasisattribute2:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.basicAttributes[2].text,TextAnchor.MiddleLeft)
		--self.basicAttributes[2].text.fontSize = 28
		--属性3
		self.basicAttributes[3] = {}
		self.basicAttributes[3].obj = self.view.textbasisattribute3
		self.basicAttributes[3].transform = self.view.textbasisattribute3:GetComponent("RectTransform")
		self.basicAttributes[3].text = self.view.textbasisattribute3:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.basicAttributes[3].text,TextAnchor.MiddleLeft)
		--self.basicAttributes[3].text.fontSize = 28
		--属性4
		self.basicAttributes[4] = {}
		self.basicAttributes[4].obj = self.view.textbasisattribute4
		self.basicAttributes[4].transform = self.view.textbasisattribute4:GetComponent("RectTransform")
		self.basicAttributes[4].text = self.view.textbasisattribute4:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.basicAttributes[4].text,TextAnchor.MiddleLeft)
		--self.basicAttributes[4].text.fontSize = 28
		--洗练属性
		--底图
		self.bgRefineTransform = self.view.bgpracticeattribute:GetComponent("RectTransform")
		--标签
		self.textRefineLabel = self.view.textpracticeattributetitle:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.textRefineLabel,TextAnchor.MiddleLeft)
		--UIUtil.AddTextOutline(self.view.textpracticeattributetitle,Color.New(242/255,179/255,121/255))
		--self.textRefineLabel.fontSize = 35
		self.textRefineLabelTransform = self.view.textpracticeattributetitle:GetComponent("RectTransform")
		self.textRefineLabel.text = uitext[1114036].NR
		--属性1
		self.refineAttributes = {}
		self.refineAttributes[1] = {}
		self.refineAttributes[1].obj = self.view.textpracticeattribute1
		self.refineAttributes[1].transform = self.view.textpracticeattribute1:GetComponent("RectTransform")
		self.refineAttributes[1].text = self.view.textpracticeattribute1:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.refineAttributes[1].text,TextAnchor.MiddleLeft)
		--self.refineAttributes[1].text.fontSize = 28
		--属性2
		self.refineAttributes[2] = {}
		self.refineAttributes[2].obj = self.view.textpracticeattribute2
		self.refineAttributes[2].transform = self.view.textpracticeattribute2:GetComponent("RectTransform")
		self.refineAttributes[2].text = self.view.textpracticeattribute2:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.refineAttributes[2].text,TextAnchor.MiddleLeft)
		--self.refineAttributes[2].text.fontSize = 28
		--属性3
		self.refineAttributes[3] = {}
		self.refineAttributes[3].obj = self.view.textpracticeattribute3
		self.refineAttributes[3].transform = self.view.textpracticeattribute3:GetComponent("RectTransform")
		self.refineAttributes[3].text = self.view.textpracticeattribute3:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.refineAttributes[3].text,TextAnchor.MiddleLeft)
		--self.refineAttributes[3].text.fontSize = 28
		--属性4
		self.refineAttributes[4] = {}
		self.refineAttributes[4].obj = self.view.textpracticeattribute4
		self.refineAttributes[4].transform = self.view.textpracticeattribute4:GetComponent("RectTransform")
		self.refineAttributes[4].text = self.view.textpracticeattribute4:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.refineAttributes[4].text,TextAnchor.MiddleLeft)
		--self.refineAttributes[4].text.fontSize = 28
		--属性5
		self.refineAttributes[5] = {}
		self.refineAttributes[5].obj = self.view.textpracticeattribute5
		self.refineAttributes[5].transform = self.view.textpracticeattribute5:GetComponent("RectTransform")
		self.refineAttributes[5].text = self.view.textpracticeattribute5:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.refineAttributes[5].text,TextAnchor.MiddleLeft)
		--self.refineAttributes[5].text.fontSize = 28
		--属性6
		self.refineAttributes[6] = {}
		self.refineAttributes[6].obj = self.view.textpracticeattribute6
		self.refineAttributes[6].transform = self.view.textpracticeattribute6:GetComponent("RectTransform")
		self.refineAttributes[6].text = self.view.textpracticeattribute6:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.refineAttributes[6].text,TextAnchor.MiddleLeft)
		--self.refineAttributes[6].text.fontSize = 28
		--属性7
		self.refineAttributes[7] = {}
		self.refineAttributes[7].obj = self.view.textpracticeattribute7
		self.refineAttributes[7].transform = self.view.textpracticeattribute7:GetComponent("RectTransform")
		self.refineAttributes[7].text = self.view.textpracticeattribute7:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.refineAttributes[7].text,TextAnchor.MiddleLeft)
		--self.refineAttributes[7].text.fontSize = 28
		--属性8
		self.refineAttributes[8] = {}
		self.refineAttributes[8].obj = self.view.textpracticeattribute8
		self.refineAttributes[8].transform = self.view.textpracticeattribute8:GetComponent("RectTransform")
		self.refineAttributes[8].text = self.view.textpracticeattribute8:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.refineAttributes[8].text,TextAnchor.MiddleLeft)
		--self.refineAttributes[8].text.fontSize = 28
		--属性9
		self.refineAttributes[9] = {}
		self.refineAttributes[9].obj = self.view.textpracticeattribute9
		self.refineAttributes[9].transform = self.view.textpracticeattribute9:GetComponent("RectTransform")
		self.refineAttributes[9].text = self.view.textpracticeattribute9:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.refineAttributes[9].text,TextAnchor.MiddleLeft)
		--self.refineAttributes[9].text.fontSize = 28
		--升星属性
		--底图
		self.bgStarTransform = self.view.bgstarattribute:GetComponent("RectTransform")
		--标签
		self.textStarLabel = self.view.textstarattributetitle:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.textStarLabel,TextAnchor.MiddleLeft)
		--UIUtil.AddTextOutline(self.view.textstarattributetitle,Color.New(242/255,179/255,121/255))
		--self.textStarLabel.fontSize = 35
		self.textStarLabelTransform = self.view.textstarattributetitle:GetComponent("RectTransform")
		self.textStarLabel.text = uitext[1114037].NR
		--属性
		self.textStarAttributeTransform = self.view.textstarattribute1:GetComponent("RectTransform")
		self.textStarAttribute = self.view.textstarattribute1:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.textStarAttribute,TextAnchor.MiddleLeft)
		--self.textStarAttribute.fontSize = 28
		--镶嵌属性
		--底图
		self.bgGemTransform = self.view.bggemattribute:GetComponent("RectTransform")
		--标签
		self.textGemLabel = self.view.textgemattributetitle:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.textGemLabel,TextAnchor.MiddleLeft)
		--UIUtil.AddTextOutline(self.view.textgemattributetitle,Color.New(242/255,179/255,121/255))
		--self.textGemLabel.fontSize = 35
		self.textGemLabelTransform = self.view.textgemattributetitle:GetComponent("RectTransform")
		self.textGemLabel.text = uitext[1114038].NR
		--属性1
		self.gemAttributes = {}
		self.gemAttributes[1] = {}
		self.gemAttributes[1].obj = self.view.gem1
		self.gemAttributes[1].transform = self.view.gem1:GetComponent("RectTransform")
		self.gemAttributes[1].text = self.view.textgemattribute1:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.gemAttributes[1].text,TextAnchor.MiddleLeft)
		--self.gemAttributes[1].text.fontSize = 28
		self.gemAttributes[1].icon = self.view.gemicon1:GetComponent("Image")
		--属性2
		self.gemAttributes[2] = {}
		self.gemAttributes[2].obj = self.view.gem2
		self.gemAttributes[2].transform = self.view.gem2:GetComponent("RectTransform")
		self.gemAttributes[2].text = self.view.textgemattribute2:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.gemAttributes[2].text,TextAnchor.MiddleLeft)
		--self.gemAttributes[2].text.fontSize = 28
		self.gemAttributes[2].icon = self.view.gemicon2:GetComponent("Image")
		--属性2
		self.gemAttributes[3] = {}
		self.gemAttributes[3].obj = self.view.gem3
		self.gemAttributes[3].transform = self.view.gem3:GetComponent("RectTransform")
		self.gemAttributes[3].text = self.view.textgemattribute3:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.gemAttributes[3].text,TextAnchor.MiddleLeft)
		--self.gemAttributes[3].text.fontSize = 28
		self.gemAttributes[3].icon = self.view.gemicon3:GetComponent("Image")
		--属性2
		self.gemAttributes[4] = {}
		self.gemAttributes[4].obj = self.view.gem4
		self.gemAttributes[4].transform = self.view.gem4:GetComponent("RectTransform")
		self.gemAttributes[4].text = self.view.textgemattribute4:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.gemAttributes[4].text,TextAnchor.MiddleLeft)
		--self.gemAttributes[4].text.fontSize = 28
		self.gemAttributes[4].icon = self.view.gemicon4:GetComponent("Image")
		--属性2
		self.gemAttributes[5] = {}
		self.gemAttributes[5].obj = self.view.gem5
		self.gemAttributes[5].transform = self.view.gem5:GetComponent("RectTransform")
		self.gemAttributes[5].text = self.view.textgemattribute5:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.gemAttributes[5].text,TextAnchor.MiddleLeft)
		--self.gemAttributes[5].text.fontSize = 28
		self.gemAttributes[5].icon = self.view.gemicon5:GetComponent("Image")
		--属性2
		self.gemAttributes[6] = {}
		self.gemAttributes[6].obj = self.view.gem6
		self.gemAttributes[6].transform = self.view.gem6:GetComponent("RectTransform")
		self.gemAttributes[6].text = self.view.textgemattribute6:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.gemAttributes[6].text,TextAnchor.MiddleLeft)
		--self.gemAttributes[6].text.fontSize = 28
		self.gemAttributes[6].icon = self.view.gemicon6:GetComponent("Image")
		--属性2
		self.gemAttributes[7] = {}
		self.gemAttributes[7].obj = self.view.gem7
		self.gemAttributes[7].transform = self.view.gem7:GetComponent("RectTransform")
		self.gemAttributes[7].text = self.view.textgemattribute7:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.gemAttributes[7].text,TextAnchor.MiddleLeft)
		--self.gemAttributes[7].text.fontSize = 28
		self.gemAttributes[7].icon = self.view.gemicon7:GetComponent("Image")
		--属性8
		self.gemAttributes[8] = {}
		self.gemAttributes[8].obj = self.view.gem8
		self.gemAttributes[8].transform = self.view.gem8:GetComponent("RectTransform")
		self.gemAttributes[8].text = self.view.textgemattribute8:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.gemAttributes[8].text,TextAnchor.MiddleLeft)
		--self.gemAttributes[8].text.fontSize = 28
		self.gemAttributes[8].icon = self.view.gemicon8:GetComponent("Image")
		--属性9
		self.gemAttributes[9] = {}
		self.gemAttributes[9].obj = self.view.gem9
		self.gemAttributes[9].transform = self.view.gem9:GetComponent("RectTransform")
		self.gemAttributes[9].text = self.view.textgemattribute9:GetComponent("TextMeshProUGUI")
		--UIUtil.SetTextAlignment(self.gemAttributes[9].text,TextAnchor.MiddleLeft)
		--self.gemAttributes[9].text.fontSize = 28
		self.gemAttributes[9].icon = self.view.gemicon9:GetComponent("Image")
		--滚动视图
		self.scrollViewContentTransform = self.view.Content:GetComponent("RectTransform")
		self.view.bgmask:SetActive(false)

        ClickEventListener.Get(self.view.btn1).onClick = OnUseBtnClick
        ClickEventListener.Get(self.view.btn2).onClick = OnEnhanceBtnClick
		ClickEventListener.Get(self.view.btntipsclose).onClick = OnCloseBtnClick
		ClickEventListener.Get(self.view.bgmask).onClick = OnCloseBtnClick

		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_LOAD_EQUIPMENT,OnLoadEquipmentReply)
		if callback ~= nil then
			callback()
		end
    end

    
    self.UpdateItemData = function(itemdata)
        if  not itemdata then
			Close()
			return
		end

		if itemdata.base_prop == nil then
			return
		end

		local itemconfig = itemtable.Item[itemdata.id]
		if not itemconfig then
			Close()
			return
		end
        
        self.view.btn1:SetActive(false)
		self.view.btn2:SetActive(false)
        self.view.star:SetActive(false)
        self.view.Labeequipped:SetActive(false)
        
        local elementstr = ""
		for basename,basevalue in pairs(itemdata.base_prop) do
			elementstr = AttributeConst.GetElementAttributeNameByIndex(basename)
			if elementstr ~= "" then
				break
			end
		end
        self.textName.text = elementstr..localization.GetItemName(itemdata.id)
		self.textName.color = QualityConst.GetQualityColor2(itemconfig.Quality)

        local equipmentconfig = equiptable.equipTemplate[itemdata.id]
        if not equipmentconfig then
			Close()
			return
		end

		self.bgicon.overrideSprite = LuaUIUtil.GetItemQuality(itemconfig.ID)
		self.imgEquipIcon.overrideSprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",itemconfig.Icon))

		self.textVocation.text = string.format(uitext[1114074].NR,VocationConst.GetVocationNameByTypes(equipmentconfig.Faction))
		local vocation_color = Color.New(1,0,0)
		for i=1,#equipmentconfig.Faction,1 do
			if equipmentconfig.Faction[i] == MyHeroManager.heroData.vocation then
				vocation_color = Color.New(26/255,24/255,29/255)
				break
			end
		end
		self.textVocation.color = vocation_color

		self.textPart.text = string.format(uitext[1114072].NR,ItemType.GetEquipPartNameByType(itemconfig.Type))

		self.textLevel.text = string.format(texttable.UIText[1114081].NR,itemconfig.LevelLimit)
		if MyHeroManager.heroData.level < itemconfig.LevelLimit then
			self.textLevel.color = Color.New(1,0,0)
		else
			self.textLevel.color = Color.New(26/255,24/255,29/255)
		end
		self.textState.text = string.format(texttable.UIText[1114073].NR,texttable.UIText[1114084].NR)
        
        local yPos = 6
		--装备评分
		self.textScore.text = uitext[1114034].NR..GetEquipScore(itemdata)
		self.textScoreTransform.anchoredPosition3D = Vector3.New(self.textScoreTransform.anchoredPosition3D.x,-yPos-24,0)
		yPos = yPos + 48
        --基础属性
		local base_prop = {}
		if itemdata.base_prop then
			self.view.textbasisattributetitle:SetActive(true)
			self.textBasicLabelTransform.anchoredPosition3D = Vector3.New(self.textBasicLabelTransform.anchoredPosition3D.x,-yPos - 24,0)
			yPos = yPos + 48
			local bgPos = yPos
			local bgHeight = 0
			local count = 0
			local base_prop = {}
			for basename,basevalue in pairs(itemdata.base_prop) do
				count = count + 1
				table.insert(base_prop,{prop=basename,value=basevalue})
			end

			if count > 1 then
				table.sort(base_prop,AttributeConst.BasePropSort)
			end

			for index=1,count,1 do
				local basename = base_prop[index].prop
				local basevalue = base_prop[index].value
				self.basicAttributes[index].obj:SetActive(true)
				self.basicAttributes[index].transform.anchoredPosition3D = Vector3.New(self.basicAttributes[index].transform.anchoredPosition3D.x,-yPos - 21,0)
				--元素属性
				if AttributeConst.IsElementAttribute(basename) then
					self.basicAttributes[index].text.color = Color.New(149/255,72/255,0)
					self.basicAttributes[index].text.text = AttributeConst.GetAttributeNameByIndex(basename).."  +"..basevalue
				else
					self.basicAttributes[index].text.color = Color.New(48/255,100/255,11/255)
					self.basicAttributes[index].text.text = AttributeConst.GetAttributeNameByIndex(basename).."  +"..basevalue
				end
				yPos = yPos + 42
				index = index + 1
				bgHeight = bgHeight + 42
			end

			self.view.bgbasisattribute:SetActive(true)
			self.bgBasicTransform.sizeDelta = Vector2.New(self.bgBasicTransform.sizeDelta.x,bgHeight)
			self.bgBasicTransform.anchoredPosition3D = Vector3.New(self.bgBasicTransform.anchoredPosition3D.x,-bgPos-bgHeight/2,0)

			for i = count + 1,4,1 do
				self.basicAttributes[i].obj:SetActive(false)
			end
		else
			self.view.bgbasisattribute:SetActive(false)
			self.view.textbasisattributetitle:SetActive(false)
			local index = 1
			for i = index,4,1 do
				self.basicAttributes[i].obj:SetActive(false)
			end
        end
        --洗练属性
			if itemdata.additional_prop then
                local index = 0
                local count = 0
				for basename,basevalue in pairs(itemdata.additional_prop) do
					count = count + 1
				end
                local indexs = {}
                for addon_k,addon_v in pairs(itemdata.additional_prop) do
                    if addon_v[3] then
                        index = index + 1
                        indexs[index] = addon_k
                    else
                        indexs[count] = addon_k
                        count = count - 1
                    end
                end
				self.view.textpracticeattributetitle:SetActive(true)
				self.textRefineLabelTransform.anchoredPosition3D = Vector3.New(self.textRefineLabelTransform.anchoredPosition3D.x,-yPos-24,0)
				yPos = yPos + 48

				local bgPos = yPos
				local bgHeight = 0
				index = 1
				local rare_count = 0
				for i,v in ipairs(indexs) do
                    local addon_v = itemdata.additional_prop[v]
					self.refineAttributes[index].obj:SetActive(true)
					self.refineAttributes[index].transform.anchoredPosition3D = Vector3.New(self.refineAttributes[index].transform.anchoredPosition3D.x,-yPos-21,0)
					if addon_v[4] == 1 then
						self.refineAttributes[index].text.text = AttributeConst.GetAttributeNameByIndex(addon_v[1]).."  +"..(addon_v[2]/100).."%"
					else
						self.refineAttributes[index].text.text = AttributeConst.GetAttributeNameByIndex(addon_v[1]).."  +"..addon_v[2]
					end
					if addon_v[3] then
						self.refineAttributes[index].text.color = Color.New(149/255,72/255,0)
						rare_count = rare_count + 1
					else
						self.refineAttributes[index].text.color = Color.New(48/255,100/255,11/255)
					end
					yPos = yPos + 42
					bgHeight = bgHeight + 42
					if rare_count < 5 then
						self.textRefineLabel.text = uitext[1114036].NR
					elseif rare_count == 5 then
						self.textRefineLabel.text = uitext[1114036].NR.."("..uitext[1114044].NR..")"
					elseif rare_count == 6 then
						self.textRefineLabel.text = uitext[1114036].NR.."("..uitext[1114045].NR..")"
					elseif rare_count == 7 then
						self.textRefineLabel.text = uitext[1114036].NR.."("..uitext[1114046].NR..")"
					elseif rare_count == 8 then
						self.textRefineLabel.text = uitext[1114036].NR.."("..uitext[1114047].NR..")"
					else
						self.textRefineLabel.text = uitext[1114036].NR.."("..uitext[1114048].NR..")"
					end
					index = index + 1

				end

				self.view.bgpracticeattribute:SetActive(true)
				self.bgRefineTransform.sizeDelta = Vector2.New(self.bgRefineTransform.sizeDelta.x,bgHeight)
				self.bgRefineTransform.anchoredPosition3D = Vector3.New(self.bgRefineTransform.anchoredPosition3D.x,-bgPos-bgHeight/2,0)

				for i = index,9,1 do
					self.refineAttributes[i].obj:SetActive(false)
				end
			else
				self.view.bgpracticeattribute:SetActive(false)
				self.view.textpracticeattributetitle:SetActive(false)
				local index = 1
				for i = index,9,1 do
					self.refineAttributes[i].obj:SetActive(false)
				end
			end
            local viewHeight = 374
			if yPos + 5 > 374 then
				viewHeight = yPos + 5
			end
			self.scrollViewContentTransform.sizeDelta = Vector2.New(0,viewHeight)
    end
    --更新数据,这个tips只显示装备
    --data.from 来源,在BagManager中定义
    --data.pos 背包中的位置 或 玩家身上装备名称
    --data.item_data 物品id
    self.UpdateData = function(data)
        if data.item_data == nil or data.item_data.id == nil or data.item_data.base_prop == nil or not ItemType.IsEquipById(data.item_data.id) then
			Close()
            return
        end

		local itemdata = data.item_data

		self.view.btn1:SetActive(true)
		self.view.btn2:SetActive(true)
		if data.from == ItemTipsFromType.BAG then
			self.view.Labeequipped:SetActive(false)
			self.textSmithingBtn.text = uitext[1115003].NR
			self.imgUseBtn.material = nil
			self.textUseBtn.material = nil
			self.view.btn1:SetActive(not BagManager.sellFlag)
			self.view.btn2:SetActive(not BagManager.sellFlag)
		elseif data.from == ItemTipsFromType.PLAYER then
			self.view.Labeequipped:SetActive(true)
			self.textSmithingBtn.text = uitext[1114057].NR
			self.imgUseBtn.material = UIGrayMaterial.GetUIGrayMaterial()
			self.textUseBtn.material = UIGrayMaterial.GetUIGrayMaterial()
		elseif data.from == ItemTipsFromType.EQUIPMENT then
			self.view.Labeequipped:SetActive(true)
			self.view.btn1:SetActive(false)
			self.view.btn2:SetActive(false)
		elseif data.from == ItemTipsFromType.NORMAL then
			self.view.Labeequipped:SetActive(false)
			self.view.btn1:SetActive(false)
			self.view.btn2:SetActive(false)
		end

		local itemconfig = itemtable.Item[itemdata.id]
		if not itemconfig then
			Close()
			return
		end

		--判断洗练按钮
		self.textSmithingBtn.material = nil
		self.imgSmithingBtn.material = nil
		if data.from == ItemTipsFromType.BAG then
			if not BagManager.IsSmeltingEquipmentByTypeAndPosition(itemconfig.Type,data.pos) then
				self.textSmithingBtn.material = UIGrayMaterial.GetUIGrayMaterial()
				self.imgSmithingBtn.material = UIGrayMaterial.GetUIGrayMaterial()
			end
		end

		self.itemdata = data

		local elementstr = ""
		for basename,basevalue in pairs(itemdata.base_prop) do
			elementstr = AttributeConst.GetElementAttributeNameByIndex(basename)
			if elementstr ~= "" then
				break
			end
		end

		if data.from == ItemTipsFromType.PLAYER and BagManager.equipment_strengthen ~= nil and BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]] ~= nil then
			if BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]].stage == 1 then
				self.textName.text = elementstr..localization.GetItemName(itemdata.id)..string.format(uitext[1114075].NR,uitext[1114076].NR,BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]].level)
			elseif BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]].stage == 2 then
				self.textName.text = elementstr..localization.GetItemName(itemdata.id)..string.format(uitext[1114075].NR,uitext[1114077].NR,BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]].level)
			elseif BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]].stage == 3 then
				self.textName.text = elementstr..localization.GetItemName(itemdata.id)..string.format(uitext[1114075].NR,uitext[1114078].NR,BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]].level)
			elseif BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]].stage == 4 then
				self.textName.text = elementstr..localization.GetItemName(itemdata.id)..string.format(uitext[1114075].NR,uitext[1114079].NR,BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]].level)
			elseif BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]].stage == 5 then
				self.textName.text = elementstr..localization.GetItemName(itemdata.id)..string.format(uitext[1114075].NR,uitext[1114080].NR,BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]].level)
			else
				self.textName.text = elementstr..localization.GetItemName(itemdata.id)
			end
		else
			self.textName.text = elementstr..localization.GetItemName(itemdata.id)
		end
		self.textName.color = QualityConst.GetQualityColor2(itemconfig.Quality)

        local equipmentconfig = equiptable.equipTemplate[itemdata.id]
        if not equipmentconfig then
			Close()
			return
		end

		self.bgicon.overrideSprite = LuaUIUtil.GetItemQuality(itemconfig.ID)
		self.imgEquipIcon.overrideSprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",itemconfig.Icon))

		self.textVocation.text = string.format(uitext[1114074].NR,VocationConst.GetVocationNameByTypes(equipmentconfig.Faction))
		local vocation_color = Color.New(1,0,0)
		for i=1,#equipmentconfig.Faction,1 do
			if equipmentconfig.Faction[i] == MyHeroManager.heroData.vocation then
				vocation_color = Color.New(26/255,24/255,29/255)
				break
			end
		end
		self.textVocation.color = vocation_color
		self.textPart.text = string.format(uitext[1114072].NR,ItemType.GetEquipPartNameByType(itemconfig.Type))

		self.textLevel.text = string.format(texttable.UIText[1114081].NR,itemconfig.LevelLimit)
		if MyHeroManager.heroData.level < itemconfig.LevelLimit then
			self.textLevel.color = Color.New(1,0,0)
		else
			self.textLevel.color = Color.New(26/255,24/255,29/255)
		end
		self.textState.text = string.format(texttable.UIText[1114073].NR,texttable.UIText[1114084].NR)
		local yPos = 6
		if itemdata then
			--星星
			if data.from == ItemTipsFromType.PLAYER and BagManager.equipment_star ~= nil and BagManager.equipment_star[equip_type_to_name[itemconfig.Type]] ~= nil and BagManager.equipment_star[equip_type_to_name[itemconfig.Type]].star > 0 then
				self.view.star:SetActive(true)
				self.starTransform.anchoredPosition3D = Vector3.New(self.starTransform.anchoredPosition3D.x,-yPos-26,0)
				for i=1,9,1 do
					if i <= BagManager.equipment_star[equip_type_to_name[itemconfig.Type]].star then
						self.stars[i]:SetActive(true)
					else
						self.stars[i]:SetActive(false)
					end
				end
				yPos = yPos + 52
			else
				self.view.star:SetActive(false)
			end

			--装备评分
			self.textScore.text = uitext[1114034].NR..GetEquipScore(itemdata)
			self.textScoreTransform.anchoredPosition3D = Vector3.New(self.textScoreTransform.anchoredPosition3D.x,-yPos-24,0)
			yPos = yPos + 48
			--基础属性
			if itemdata.base_prop then
				self.view.textbasisattributetitle:SetActive(true)
				self.textBasicLabelTransform.anchoredPosition3D = Vector3.New(self.textBasicLabelTransform.anchoredPosition3D.x,-yPos - 24,0)
				yPos = yPos + 48
				local bgPos = yPos
				local bgHeight = 0
				local count = 0
				local base_prop = {}
				for basename,basevalue in pairs(itemdata.base_prop) do
					count = count + 1
					table.insert(base_prop,{prop=basename,value=basevalue})
				end

				if count > 1 then
					table.sort(base_prop,AttributeConst.BasePropSort)
				end

				for index=1,count,1 do
					local basename = base_prop[index].prop
					local basevalue = base_prop[index].value
					self.basicAttributes[index].obj:SetActive(true)
					self.basicAttributes[index].transform.anchoredPosition3D = Vector3.New(self.basicAttributes[index].transform.anchoredPosition3D.x,-yPos - 21,0)
					--元素属性
					if AttributeConst.IsElementAttribute(basename) then
						self.basicAttributes[index].text.color = Color.New(149/255,72/255,0)
						self.basicAttributes[index].text.text = AttributeConst.GetAttributeNameByIndex(basename).."  +"..basevalue
					else
						self.basicAttributes[index].text.color = Color.New(48/255,100/255,11/255)
						if data.from == ItemTipsFromType.PLAYER and BagManager.equipment_strengthen ~= nil and BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]] ~= nil then
							--计算强化效果
							local strengthen = BagManager.equipment_strengthen[equip_type_to_name[itemconfig.Type]]
							local strengthen_value = 0
							for i=1,strengthen.stage,1 do
								local fixed = 0
								local percent = 0
								local addition_cfg = equipment_strengthen_config.get_strengthen_addition(equip_type_to_name[itemconfig.Type],i,basename)
								if addition_cfg ~= nil then
									if i == strengthen.stage then
										fixed = fixed + addition_cfg.fixed*strengthen.level
										percent = percent + addition_cfg.percent*strengthen.level
									else
										fixed = fixed + addition_cfg.fixed*MAX_STRENGTHEN_LEVEL
										percent = percent + addition_cfg.percent*MAX_STRENGTHEN_LEVEL
									end
								end
								strengthen_value = basevalue + fixed + math.floor(basevalue*percent/100)
							end
							strengthen_value = math.floor(strengthen_value)
							self.basicAttributes[index].text.text = AttributeConst.GetAttributeNameByIndex(basename).."  +"..basevalue..string.format(uitext[1114082].NR,strengthen_value)
						else
							self.basicAttributes[index].text.text = AttributeConst.GetAttributeNameByIndex(basename).."  +"..basevalue
						end
					end
					yPos = yPos + 42
					index = index + 1
					bgHeight = bgHeight + 42
				end

				self.view.bgbasisattribute:SetActive(true)
				self.bgBasicTransform.sizeDelta = Vector2.New(self.bgBasicTransform.sizeDelta.x,bgHeight)
				self.bgBasicTransform.anchoredPosition3D = Vector3.New(self.bgBasicTransform.anchoredPosition3D.x,-bgPos-bgHeight/2,0)

				for i = count + 1,4,1 do
					self.basicAttributes[i].obj:SetActive(false)
				end
			else
				self.view.bgbasisattribute:SetActive(false)
				self.view.textbasisattributetitle:SetActive(false)
				local index = 1
				for i = index,4,1 do
					self.basicAttributes[i].obj:SetActive(false)
				end
			end
			--洗练属性
			if itemdata.additional_prop then
                local index = 0
                local count = 0
				for basename,basevalue in pairs(itemdata.additional_prop) do
					count = count + 1
				end
                local indexs = {}
                for addon_k,addon_v in pairs(itemdata.additional_prop) do
                    if addon_v[3] then
                        index = index + 1
                        indexs[index] = addon_k
                    else
                        indexs[count] = addon_k
                        count = count - 1
                    end
                end
				self.view.textpracticeattributetitle:SetActive(true)
				self.textRefineLabelTransform.anchoredPosition3D = Vector3.New(self.textRefineLabelTransform.anchoredPosition3D.x,-yPos-24,0)
				yPos = yPos + 48

				local bgPos = yPos
				local bgHeight = 0
				index = 1
				local rare_count = 0
				for i,v in ipairs(indexs) do
                    local addon_v = itemdata.additional_prop[v]
					self.refineAttributes[index].obj:SetActive(true)
					self.refineAttributes[index].transform.anchoredPosition3D = Vector3.New(self.refineAttributes[index].transform.anchoredPosition3D.x,-yPos-21,0)
					if addon_v[4] == 1 then
						self.refineAttributes[index].text.text = AttributeConst.GetAttributeNameByIndex(addon_v[1]).."  +"..(addon_v[2]/100).."%"
					else
						self.refineAttributes[index].text.text = AttributeConst.GetAttributeNameByIndex(addon_v[1]).."  +"..addon_v[2]
					end
					if addon_v[3] then
						self.refineAttributes[index].text.color = Color.New(149/255,72/255,0)
						rare_count = rare_count + 1
					else
						self.refineAttributes[index].text.color = Color.New(48/255,100/255,11/255)
					end
					yPos = yPos + 42
					bgHeight = bgHeight + 42
					if rare_count < 5 then
						self.textRefineLabel.text = uitext[1114036].NR
					elseif rare_count == 5 then
						self.textRefineLabel.text = uitext[1114036].NR.."("..uitext[1114044].NR..")"
					elseif rare_count == 6 then
						self.textRefineLabel.text = uitext[1114036].NR.."("..uitext[1114045].NR..")"
					elseif rare_count == 7 then
						self.textRefineLabel.text = uitext[1114036].NR.."("..uitext[1114046].NR..")"
					elseif rare_count == 8 then
						self.textRefineLabel.text = uitext[1114036].NR.."("..uitext[1114047].NR..")"
					else
						self.textRefineLabel.text = uitext[1114036].NR.."("..uitext[1114048].NR..")"
					end
					index = index + 1

				end

				self.view.bgpracticeattribute:SetActive(true)
				self.bgRefineTransform.sizeDelta = Vector2.New(self.bgRefineTransform.sizeDelta.x,bgHeight)
				self.bgRefineTransform.anchoredPosition3D = Vector3.New(self.bgRefineTransform.anchoredPosition3D.x,-bgPos-bgHeight/2,0)

				for i = index,9,1 do
					self.refineAttributes[i].obj:SetActive(false)
				end
			else
				self.view.bgpracticeattribute:SetActive(false)
				self.view.textpracticeattributetitle:SetActive(false)
				local index = 1
				for i = index,9,1 do
					self.refineAttributes[i].obj:SetActive(false)
				end
			end
			--升星属性
			if data.from == ItemTipsFromType.PLAYER and BagManager.equipment_star ~= nil and BagManager.equipment_star[equip_type_to_name[itemconfig.Type]] ~= nil and BagManager.equipment_star[equip_type_to_name[itemconfig.Type]].star > 0 then
				self.view.textstarattributetitle:SetActive(true)
				self.textStarLabelTransform.anchoredPosition3D = Vector3.New(self.textStarLabelTransform.anchoredPosition3D.x,-yPos-24,0)
				yPos = yPos + 48
				self.view.bgstarattribute:SetActive(true)
				self.bgStarTransform.anchoredPosition3D = Vector3.New(self.bgStarTransform.anchoredPosition3D.x,-yPos-self.bgStarTransform.sizeDelta.y/2,0)
				self.view.textstarattribute1:SetActive(true)
				self.textStarAttributeTransform.anchoredPosition3D = Vector3.New(self.textStarAttributeTransform.anchoredPosition3D.x,-yPos-21,0)
				local star_config = equipment_star.Bless[BagManager.equipment_star[equip_type_to_name[itemconfig.Type]].star]
				if star_config then
					self.textStarAttribute.text = uitext[1114032].NR.."  +"..star_config.spiritual
				else
					self.textStarAttribute.text = uitext[1114032].NR.."  +0"
				end
				yPos = yPos + 42
			else
				self.view.textstarattributetitle:SetActive(false)
				self.view.bgstarattribute:SetActive(false)
				self.view.textstarattribute1:SetActive(false)
			end
			--镶嵌宝石
			local gem_index = 0
			if data.from == ItemTipsFromType.PLAYER and GemManager.gemInfo ~= nil and GemManager.gemInfo[equip_type_to_name[itemconfig.Type]] ~= nil then
				self.view.textgemattributetitle:SetActive(true)
				self.textGemLabelTransform.anchoredPosition3D = Vector3.New(self.textGemLabelTransform.anchoredPosition3D.x,-yPos-24,0)
				yPos = yPos + 48
				local bgPos = yPos
				local bgHeight = 0
				local gem = {}
				for i=1,9,1 do
					if GemManager.gemInfo[equip_type_to_name[itemconfig.Type]].slots[i] > 0 then
						if gem[GemManager.gemInfo[equip_type_to_name[itemconfig.Type]].slots[i]] == nil then
							gem_index = gem_index + 1
							self.gemAttributes[gem_index].obj:SetActive(true)
							self.gemAttributes[gem_index].transform.anchoredPosition3D = Vector3.New(self.gemAttributes[gem_index].transform.anchoredPosition3D.x,-yPos - 21,0)
							local gem_item_config = itemtable.Item[GemManager.gemInfo[equip_type_to_name[itemconfig.Type]].slots[i]]
							if gem_item_config ~= nil then
								self.gemAttributes[gem_index].icon.overrideSprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",gem_item_config.Icon))
							end

							yPos = yPos + 42
							bgHeight = bgHeight + 42
							gem[GemManager.gemInfo[equip_type_to_name[itemconfig.Type]].slots[i]] = true
							local item_gem_config = item_gem_configs[GemManager.gemInfo[equip_type_to_name[itemconfig.Type]].slots[i]]
							print(table.serialize(item_gem_config))
							if item_gem_config ~= nil then
								if item_gem_config.attribute_value_type == equipment_attribute_value_type.normal then       --value_type为2的是正常属性加成
									self.gemAttributes[gem_index].text.text = AttributeConst.GetAttributeNameByIndex(item_gem_config.attribute_index).."  +"..item_gem_config.attribute_value
								elseif item_gem_config.attribute_value_type == equipment_attribute_value_type.percent then        --value_type为1的是百分比属性加成
									self.gemAttributes[gem_index].text.text = AttributeConst.GetAttributeNameByIndex(item_gem_config.attribute_index).."  +"..(item_gem_config.attribute_value/100).."%"
								end
							end
						end
					end
				end
				self.view.bggemattribute:SetActive(true)
				self.bgGemTransform.sizeDelta = Vector2.New(self.bgGemTransform.sizeDelta.x,bgHeight)
				self.bgGemTransform.anchoredPosition3D = Vector3.New(self.bgGemTransform.anchoredPosition3D.x,-bgPos - bgHeight/2,0)
			end
			if gem_index == 0 then
				self.view.textgemattributetitle:SetActive(false)
				self.view.bggemattribute:SetActive(false)
			end

			for i=gem_index + 1,9,1 do
				self.gemAttributes[i].obj:SetActive(false)
			end


			local viewHeight = 374
			if yPos + 5 > 374 then
				viewHeight = yPos + 5
			end
			self.scrollViewContentTransform.sizeDelta = Vector2.New(0,viewHeight)
		end
	end

	self.UpdatePosition = function(x,y)
		self.view.transform.anchoredPosition3D = Vector3.New(x,y,0)
	end

	self.SetBgMaskActive = function(value)
		if value == true then
			self.view.bgmask:SetActive(true)
		else
			self.view.bgmask:SetActive(false)
		end
	end

	self.onUnload = function()

	end
	return self
end

