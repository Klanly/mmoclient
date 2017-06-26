---------------------------------------------------
-- auth： panyinglong
-- date： 2016/11/11
-- desc： 技能
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
local localization = require "Common/basic/Localization"
local texttable = require "Logic/Scheme/common_char_chinese"
local config = require "Logic/Scheme/growing_skill"
local item_config = require "Logic/Scheme/common_item"

local zhaoshi_selected = false
local skill_selected = false

-- 技能预设item
local function CreatePresetItemUI(template, data)
	local self = CreateScrollviewItem(template)

	local index = data
	self.txtIndex = self.transform:FindChild('index').gameObject
    self.imgSelect = self.transform:FindChild('selectimg').gameObject
	self.imgPreset = self.transform:FindChild('bgPresetskill').gameObject

	self.txtIndex:GetComponent('TextMeshProUGUI').text = index

    ClickEventListener.Get(self.imgPreset).onClick = function()
    	--print('ClickEventListener.Get(self.imgPreset).onClick', self.txtIndex)
    	UIManager.GetCtrl(ViewAssets.SkillSet).choosePresetItem(index)
    end 

    self.SetSelect = function(b)
		self.imgSelect:SetActive(b)
	end
	self.SetSelect(false)
	return self
end

-- 基类
local function CreateItem(template)
	local self = CreateObject()
	self.gameObject = template
	self.transform = template.transform
	return self
end

local function GetSlotName(slot_id)

	local name_id = config.SkillMoves[MyHeroManager.heroData.vocation * 1000 + slot_id].Name
	return localization.GetChineseName(name_id)
end

local function GetSlotConfig(slot_id)
	return config.SkillMoves[MyHeroManager.heroData.vocation * 1000 + slot_id]
end

-- 左边的按钮item (XX诀)
local function CreateGroupBtnItem(template, data)
	local defImg = 'AutoGenerate/SkillSet/btn_tactic'
	local selImg = 'AutoGenerate/SkillSet/btn_down3'
	local defColor = Color.New(235/255, 219/255, 203/255)
	local selColor = Color.New(68/255, 42/255, 24/255)

	local self = CreateItem(template)
	self.imgBtn = self.transform:FindChild('btn').gameObject
	self.txtName = self.transform:FindChild('name').gameObject

	self.txtName:GetComponent('TextMeshProUGUI').text = GetSlotName(data.index)

	self.isSelect = false

	self.index = data.index 

    ClickEventListener.Get(self.imgBtn).onClick = function()
    	--print(self.txtName:GetComponent('TextMeshProUGUI').text)
    	--self.SetSelect(not self.isSelect)
    	UIManager.GetCtrl(ViewAssets.SkillSet).chooseSkillGroup(self.index)
    end 

	self.SetSelect = function(b)
		local img = defImg
		local color = defColor
		if b then
			self.imgBtn:GetComponent('Image').sprite = ResourceManager.LoadSprite(selImg)
			self.txtName:GetComponent('TextMeshProUGUI').color = selColor
			--self.transform.position = Vector3.New(self.transform.position.x + 2, self.transform.position.y, self.transform.position.z)
		else
			self.imgBtn:GetComponent('Image').sprite = ResourceManager.LoadSprite(defImg)
			self.txtName:GetComponent('TextMeshProUGUI').color = defColor			
			--self.transform.position = Vector3.New(self.transform.position.x - 2, self.transform.position.y, self.transform.position.z)
		end
		self.isSelect = b
	end

	self.SetSelect(false)
	return self
end

local function GetCurrentLevel()
	return MyHeroManager.heroData.skill_level[UIManager.GetCtrl(ViewAssets.SkillSet).current_skill_group]
end

-- 中间的item
local function CreateGroupSkillItem(template, data)
	local self = CreateItem(template)
	self.imgskill = self.transform:FindChild('imgskill').gameObject
	self.imgselect = self.transform:FindChild('imgselect').gameObject
	self.imgLock = self.transform:FindChild('imgLock').gameObject
	self.imgBg = self.transform:FindChild('bg').gameObject

	self.index = data.index
	self.locked = false

	ClickEventListener.Get(self.imgBg).onClick = function()
    	UIManager.GetCtrl(ViewAssets.SkillSet).chooseSkill(self.index)
    end 

    self.OnDataChanged = function()
	    if UIManager.GetCtrl(ViewAssets.SkillSet).current_skill_group == nil then
	    	return 
	    end
    	local tmp = config.SkillMoves[MyHeroManager.heroData.vocation * 1000 + UIManager.GetCtrl(ViewAssets.SkillSet).current_skill_group]
    	self.skill_id = tostring(tmp.SkillID[self.index])

    	local unlock_level = config.SkillUnlock[tonumber(self.skill_id)].PlayerLv
    	local skill_data = config.Skill[tonumber(self.skill_id)]

    	if skill_data then
    		self.imgskill:GetComponent('Image').sprite = ResourceManager.LoadSprite('SkillIcons/'..skill_data.Icon)
    	end

    	if --[[skill_data and ]]unlock_level <= MyHeroManager.heroData.level then	
    		self.imgLock:SetActive(false)
    		self.locked = false
    		self.imgskill:GetComponent('Image').material = nil
    	else
    		self.imgLock:SetActive(true)
    		self.locked = true
    		self.imgskill:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
    	end
	end

	self.SetSelect = function(b)
		self.imgselect:SetActive(b)

		if (b) then
			local skill_data = config.Skill[tonumber(self.skill_id)]
			if skill_data then
				UIManager.GetCtrl(ViewAssets.SkillSet).view.textskillname:GetComponent('TextMeshProUGUI').text = skill_data.Name1
				if skill_data.Description ~= "0" then
					UIManager.GetCtrl(ViewAssets.SkillSet).view.textskilldescribe:GetComponent('TextMeshProUGUI').text = 
						SkillAPI.GetSkillDescription(self.skill_id, GetCurrentLevel())
				else
					UIManager.GetCtrl(ViewAssets.SkillSet).view.textskilldescribe:GetComponent('TextMeshProUGUI').text = ""
				end
				
			end

		end
	end

	self.SetSelect(false)
	self.OnDataChanged()
	return self
end

-- 底部的item
local function CreateSlotSkillItem(template, data)
	local self = CreateItem(template)
	self.bg = self.transform:FindChild('bg').gameObject
	self.imgskill = self.transform:FindChild('imgskill').gameObject
	self.imgselect = self.transform:FindChild('imgselect').gameObject

	self.index = data.index

	ClickEventListener.Get(self.bg).onClick = function()
    	UIManager.GetCtrl(ViewAssets.SkillSet).chooseSkillGroup(self.index)
    end

	self.OnDataChanged = function()
		if SceneManager.GetEntityManager().hero.skillManager.skills[self.index] then
			local icon = SceneManager.GetEntityManager().hero.skillManager.skills[self.index].Icon
			self.imgskill:SetActive(true)
	    	self.imgskill:GetComponent('Image').sprite = ResourceManager.LoadSprite(icon)
	    else
	    	self.imgskill:SetActive(false)
	    end
	end
	self.SetSelect = function(b)
		self.imgselect:SetActive(b)
	end

	self.SetSelect(false)
	self.OnDataChanged()
	return self
end

local function refreshAllDynamicSetting()
	-- 当前预选方案
	if UIManager.GetCtrl(ViewAssets.SkillSet).current_preset_index ~= nil then
		UIManager.GetCtrl(ViewAssets.SkillSet).presetItems[UIManager.GetCtrl(ViewAssets.SkillSet).current_preset_index].SetSelect(false)
	end
	UIManager.GetCtrl(ViewAssets.SkillSet).current_preset_index = MyHeroManager.heroData.cur_plan
	UIManager.GetCtrl(ViewAssets.SkillSet).presetItems[UIManager.GetCtrl(ViewAssets.SkillSet).current_preset_index].SetSelect(true)

	for k,v in pairs(UIManager.GetCtrl(ViewAssets.SkillSet).groupSlotItems) do 
		v.OnDataChanged()
	end

	for k,v in pairs(UIManager.GetCtrl(ViewAssets.SkillSet).groupSkillItems) do 
		v.OnDataChanged()
	end

	-- 中间那一块
	local current_level = MyHeroManager.heroData.skill_level[UIManager.GetCtrl(ViewAssets.SkillSet).current_skill_group]
	UIManager.GetCtrl(ViewAssets.SkillSet).view.textTacticname:GetComponent('TextMeshProUGUI').text = GetSlotName(UIManager.GetCtrl(ViewAssets.SkillSet).current_skill_group)
	UIManager.GetCtrl(ViewAssets.SkillSet).view.textTacticdescribe:GetComponent('TextMeshProUGUI').text = 
		texttable.TableText[GetSlotConfig(UIManager.GetCtrl(ViewAssets.SkillSet).current_skill_group).Character].NR
	UIManager.GetCtrl(ViewAssets.SkillSet).view.textTacticlv:GetComponent('TextMeshProUGUI').text = 
		tostring(GetCurrentLevel())

	local skill = SceneManager.GetEntityManager().hero.skillManager.skills[UIManager.GetCtrl(ViewAssets.SkillSet).current_skill_group]


	if skill and UIManager.GetCtrl(ViewAssets.SkillSet).current_skill and 
		skill.skill_id == UIManager.GetCtrl(ViewAssets.SkillSet).groupSkillItems[UIManager.GetCtrl(ViewAssets.SkillSet).current_skill].skill_id then

		UIManager.GetCtrl(ViewAssets.SkillSet).view.picusing:SetActive(true)
		UIManager.GetCtrl(ViewAssets.SkillSet).view.textuseingtips:SetActive(false)
	else
		UIManager.GetCtrl(ViewAssets.SkillSet).view.picusing:SetActive(false)
		UIManager.GetCtrl(ViewAssets.SkillSet).view.textuseingtips:SetActive(true)
	end

	-- 升级消耗
	UIManager.GetCtrl(ViewAssets.SkillSet).view.textupgradename:GetComponent('TextMeshProUGUI').text = GetSlotName(UIManager.GetCtrl(ViewAssets.SkillSet).current_skill_group)..'·修炼'
	local cost1_id = config.UpgradeCost[tostring(UIManager.GetCtrl(ViewAssets.SkillSet).current_skill_group)..'_'..tostring(current_level)].Cost1[1]
	local cost1_name = item_config.Item[cost1_id].Name1
	local cost2_id = config.UpgradeCost[tostring(UIManager.GetCtrl(ViewAssets.SkillSet).current_skill_group)..'_'..tostring(current_level)].Cost2[1]
	local cost2_name = item_config.Item[cost2_id].Name1
	local cost1 = config.UpgradeCost[tostring(UIManager.GetCtrl(ViewAssets.SkillSet).current_skill_group)..'_'..tostring(current_level)].Cost1[2]
	local cost2 = config.UpgradeCost[tostring(UIManager.GetCtrl(ViewAssets.SkillSet).current_skill_group)..'_'..tostring(current_level)].Cost2[2]
	UIManager.GetCtrl(ViewAssets.SkillSet).view.texticonconsume1:GetComponent('TextMeshProUGUI').text = cost1_name
	UIManager.GetCtrl(ViewAssets.SkillSet).view.texticonconsume2:GetComponent('TextMeshProUGUI').text = cost2_name

	UIManager.GetCtrl(ViewAssets.SkillSet).view.textHave1:GetComponent('TextMeshProUGUI').text = '拥有:'..BagManager.GetItemNumberById(cost1_id)
	if BagManager.GetTotalCoin() < cost1 then
		UIManager.GetCtrl(ViewAssets.SkillSet).view.textHave1:GetComponent('TextMeshProUGUI').color = Color.New(255/255,0/255,0/255)
	else
		UIManager.GetCtrl(ViewAssets.SkillSet).view.textHave1:GetComponent('TextMeshProUGUI').color = Color.New(229/255,210/255,193/255)
	end
	UIManager.GetCtrl(ViewAssets.SkillSet).view.textHave2:GetComponent('TextMeshProUGUI').text = '拥有:'..BagManager.GetItemNumberById(cost2_id)
	if BagManager.GetItemNumberById(cost2_id) < cost2 then
		UIManager.GetCtrl(ViewAssets.SkillSet).view.textHave2:GetComponent('TextMeshProUGUI').color = Color.New(255/255,0/255,0/255)
	else
		UIManager.GetCtrl(ViewAssets.SkillSet).view.textHave2:GetComponent('TextMeshProUGUI').color = Color.New(229/255,210/255,193/255)
	end
	UIManager.GetCtrl(ViewAssets.SkillSet).view.textconsume1:GetComponent('TextMeshProUGUI').text = '消耗:'..cost1
	UIManager.GetCtrl(ViewAssets.SkillSet).view.textconsume2:GetComponent('TextMeshProUGUI').text = '消耗:'..cost2

	-- 招式 和 技能 选中 状态
	UIManager.GetCtrl(ViewAssets.SkillSet).view.upgradeui:SetActive(zhaoshi_selected)
	UIManager.GetCtrl(ViewAssets.SkillSet).view.btnTacticSelected:SetActive(zhaoshi_selected)
	UIManager.GetCtrl(ViewAssets.SkillSet).view.useingui:SetActive(skill_selected)
	for _,v in ipairs(UIManager.GetCtrl(ViewAssets.SkillSet).groupSkillItems) do
		v.SetSelect(false)
	end

	if UIManager.GetCtrl(ViewAssets.SkillSet).current_skill then
		UIManager.GetCtrl(ViewAssets.SkillSet).groupSkillItems[UIManager.GetCtrl(ViewAssets.SkillSet).current_skill].SetSelect(true)
	end


end

-- 招式被选中
local function SetZhaoShiSelected(flag)
	zhaoshi_selected = flag
	skill_selected = not flag
	if not skill_selected then
		UIManager.GetCtrl(ViewAssets.SkillSet).current_skill = nil
	end
	refreshAllDynamicSetting()
end

-- 初始化 一些 按钮
local function initButtons( controller)
	-- 技能使用 按钮
	UIUtil.AddButtonEffect(controller.view.btnuseing, nil, nil)
	ClickEventListener.Get(controller.view.btnuseing).onClick = function()
    	controller.ChangeSlotSkill()
    end 

    -- 中间的 选择 招式 按钮
    UIUtil.AddButtonEffect(controller.view.btnTactic, nil, nil)
    ClickEventListener.Get(controller.view.btnTactic).onClick = function()
    	SetZhaoShiSelected(true)
    end 

    -- 升级按钮
    UIUtil.AddButtonEffect(controller.view.btnupgrade, nil, nil)
	ClickEventListener.Get(controller.view.btnupgrade).onClick = function()
		local cl = GetCurrentLevel()
		local skill_config = config.UpgradeCost[tostring(controller.current_skill_group)..'_'..tostring(cl)]
		if skill_config ~= nil then
			local cost_items = {}
			table.insert(cost_items,table.copy(skill_config.Cost1))
			table.insert(cost_items,table.copy(skill_config.Cost2))
			if BagManager.CheckItemIsEnough(cost_items) == false then
				return
			end
			BagManager.CheckBindCoinIsEnough(cost_items,function()
				MyHeroManager.UpgradeSkill(controller.current_skill_group)
			end)
		end
    end
end

-- 控制器
local function CreateSkillSetCtrl()
	local self = CreateCtrlBase()
	self.presetItems = {} 	-- 预设items

	self.groupBtnItems = {}	
	self.groupSkillItems = {}
	self.groupSlotItems = {}

	local clearPresetItems = function()
		for k, v in pairs(self.presetItems) do			
			DestroyScrollviewItem(v)
		end
		self.presetItems = {}
	end

	local onCloseClick = function()
		print('popview')
		UIManager.UnloadView(ViewAssets.SkillSet)
	end
	-- 当加载完时
	self.onLoad = function(...)
		print('Skill Set On Load')
		self.presetItemTemplate = self.view.itemtemplate
		self.presetItemTemplate:SetActive(false)

	    ClickEventListener.Get(self.view.btnclose).onClick = onCloseClick
		-- 先添加６个预设
		for i = 1, 6 do
			local item = CreatePresetItemUI(self.presetItemTemplate, i)
			table.insert(self.presetItems, item)
		end

		-- 
		for i = 1, 4 do
			-- btn
			local item = CreateGroupBtnItem(self.view['choosegroup'..i], { index = i })
			table.insert(self.groupBtnItems, item)

			-- 
			item = CreateGroupSkillItem(self.view['skillgroup'..i], { index = i })
			table.insert(self.groupSkillItems, item)

			-- 
			item = CreateSlotSkillItem(self.view['slotgroup'..i], {index = i})
			table.insert(self.groupSlotItems, item)
		end

		self.chooseSkillGroup(1)


		-- 特效关闭
		for i = 1,4 do
			UIManager.GetCtrl(ViewAssets.SkillSet).view["effectupgradeskill"..i]:SetActive(false)
		end
		UIManager.GetCtrl(ViewAssets.SkillSet).view.effectupgradeall:SetActive(false)
		
		initButtons(self)

		refreshAllDynamicSetting()

		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, refreshAllDynamicSetting)
	end

	self.choosePresetItem = function(index)
		MyHeroManager.ChangeSkillPlan(index)
	end

	-- 选择招式
	self.chooseSkillGroup = function(index)
		--print('chooseSkillGroup', index)
		self.chooseSkill(nil)
		if self.current_skill_group ~= nil then
			self.groupBtnItems[self.current_skill_group].SetSelect(false)
			self.groupSlotItems[self.current_skill_group].SetSelect(false)
		end
		self.current_skill_group = index
		self.groupBtnItems[index].SetSelect(true)
		self.groupSlotItems[index].SetSelect(true)

		SetZhaoShiSelected(true)

		refreshAllDynamicSetting()
	end

	-- 选中 技能group
	self.chooseSkill = function(index)
		if index ~= nil and self.groupSkillItems[index].locked then
			return 
		end
		if self.current_skill ~= nil then
			self.groupSkillItems[self.current_skill].SetSelect(false)
		end

		if index ~= nil then
			self.current_skill = index
			SetZhaoShiSelected(false)
		end

	end

	self.ChangeSlotSkill = function()

		MyHeroManager.ChangeSkill(
			self.current_skill_group,
			tonumber(self.groupSkillItems[self.current_skill].skill_id),
			self.current_preset_index )
	end

	self.OnSkillUpgrade = function()

		for i = 1,4 do
			if not self.groupSkillItems[i].locked then
				UIManager.GetCtrl(ViewAssets.SkillSet).view["effectupgradeskill"..i]:SetActive(false)
				UIManager.GetCtrl(ViewAssets.SkillSet).view["effectupgradeskill"..i]:SetActive(true)
			end
		end
		UIManager.GetCtrl(ViewAssets.SkillSet).view.effectupgradeall:SetActive(false)
		UIManager.GetCtrl(ViewAssets.SkillSet).view.effectupgradeall:SetActive(true)
	end

	-- 当销毁(回收)时
	self.onUnload = function()
		clearPresetItems()
		self.groupBtnItems = {}	
		self.groupSkillItems = {}
		self.groupSlotItems = {}
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, refreshAllDynamicSetting)
	end

	-- 当view获得焦点时（比如从底层到顶层，或view加载之前）
	self.onActive = function()
	end

	-- 当失去焦点时事件（比如，从顶层到底层、或view卸载之前）
	self.onDeactive = function()
	end

	return self
end

return CreateSkillSetCtrl()