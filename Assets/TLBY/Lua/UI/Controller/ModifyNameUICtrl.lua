---------------------------------------------------
-- auth： tml
-- date： 02/14/2017
-- desc： 改名
---------------------------------------------------

local constant = require "Common/constant"
local math = require "math"
local systemLoginCreate = systemLoginCreate
local uitext = GetConfig("common_char_chinese").UIText
local item_configs = GetConfig("common_item").Item
local string_utf8len = string.utf8len

local function CreateModifyNameUICtrl()
	local self = CreateCtrlBase()
	self.layer = LayerGroup.popCanvas
	self.item_pos = 0
	self.item_id = 0

	local onCloseBtnClick = function()
		self.close()
	end

	local onRandomNameBtnClick = function()
		local sex = MyHeroManager.heroData.sex

		local length = #systemLoginCreate.FristName
		local ran = math.random(1, length)
		local firstName = systemLoginCreate.FristName[ran].FirstName
		local secondName

		if sex == 1 then		--男性
			length = #systemLoginCreate.RandManName
			ran = math.random(1, length)
			secondName = systemLoginCreate.RandManName[ran].ManName
		else   --女性
			length = #systemLoginCreate.RandWomanName
			ran = math.random(1, length)
			secondName = systemLoginCreate.RandWomanName[ran].WomanName
		end

		local name = firstName .. secondName
		self.nameText.text = name
	end

	local onCancelBtnClick = function()
		self.close()
	end

	local onConfirmBtnClick = function()
		local data = {}

		local name = string.trim(self.nameText.text)
		if string_utf8len(name) <= constant.PLAYER_NAME_MIN_LENTH or string_utf8len(name) >= constant.PLAYER_NAME_MAX_LENTH then
			UIManager.ShowNotice(string.format("名字长度必须大于%d字符或小于%d字符",constant.PLAYER_NAME_MIN_LENTH,constant.PLAYER_NAME_MAX_LENTH))
			return
		end

		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC,{func_name="on_change_name",item_pos=self.item_pos,item_id=self.item_id,name=self.nameText.text})
	end

	self.onLoad = function(item_pos,item_id)
		BagManager.lock = true
		self.item_pos = item_pos
		self.item_id = item_id

		self.titleLabel = self.view.com_text_s1:GetComponent("TextMeshProUGUI")
		self.titleLabel.text = uitext[1101061].NR
		self.costLabel = self.view.com_text_s3:GetComponent("TextMeshProUGUI")
		self.costLabel.text = uitext[1101062].NR
		self.nameText = self.view.textEntername:GetComponent("TMP_InputField")
		self.confirmLabel = self.view.com_text_btn_3_1:GetComponent("TextMeshProUGUI")
		self.confirmLabel.text = uitext[1101006].NR
		self.cancelLabel = self.view.com_text_btn_3_2:GetComponent("TextMeshProUGUI")
		self.cancelLabel.text = uitext[1101007].NR

		ClickEventListener.Get(self.view.com_btnclose2).onClick = onCloseBtnClick
        UIUtil.AddButtonEffect(self.view.com_btnclose2, nil, nil)
		ClickEventListener.Get(self.view.icondice).onClick = onRandomNameBtnClick
        UIUtil.AddButtonEffect(self.view.icondice, nil, nil)
		ClickEventListener.Get(self.view.com_btn_3_2).onClick = onCancelBtnClick
        UIUtil.AddButtonEffect(self.view.com_btn_3_2, nil, nil)
		ClickEventListener.Get(self.view.com_btn_3_1).onClick = onConfirmBtnClick
        UIUtil.AddButtonEffect(self.view.com_btn_3_1, nil, nil)

		local item_config = item_configs[item_id]
		if item_config ~= nil then
			self.view.icon1:GetComponent("Image").overrideSprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",item_config.Icon))
		end
		onRandomNameBtnClick()
	end
	
	self.onUnload = function()
		BagManager.lock = false
	end
	
	return self
end

return CreateModifyNameUICtrl()