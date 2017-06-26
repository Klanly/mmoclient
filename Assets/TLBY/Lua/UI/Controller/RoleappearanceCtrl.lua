require "UI/Controller/LuaCtrlBase"
local constant = require "Common/constant"
local itemTable = require "Logic/Scheme/common_item"
local growingFashion = require "Logic/Scheme/growing_fashion"
local texttable = require "Logic/Scheme/common_char_chinese"

local function CreateRoleappearanceCtrl()
    local self = CreateCtrlBase()
	local dressTable = GetConfig('growing_fashion').Fashion
	self.rolemodel = nil
	ItemID = -1
	FashionID = -1
	local yPos = 74
	local height = 600
	local FilterTypes = {}
	local FashiongItemList = {} 
	local FashiongIDList = {} 
	local bRubbing = false
	local function OnCloseUI()
         self.close()
    end
	
    local function OnBackUI()
		if bRubbing == false then return end
		self.view.RubbingAppearanceUI:SetActive(false)
		self.view.AppearanceMaterialBasic:SetActive(true)
		self.MaterialListTransform.anchoredPosition3D = Vector3.New(self.MaterialListTransform.anchoredPosition.x,yPos,0)
		self.Bg4Transform.sizeDelta = Vector2.New(self.Bg4Transform.sizeDelta.x,height)
		bRubbing = false
		end

	local function RubbingClick()
		if bRubbing then return end
        self.view.RubbingAppearanceUI:SetActive(true)
		self.view.AppearanceMaterialBasic:SetActive(false)
		self.MaterialListTransform.anchoredPosition3D = Vector3.New(self.MaterialListTransform.anchoredPosition.x,yPos-152,0)
		self.Bg4Transform.sizeDelta = Vector2.New(self.Bg4Transform.sizeDelta.x,height - 170)
		bRubbing = true
    end
	
	local function SaveHeroFashion()
		if FashionID ~= -1 then
			local data = {}
			data.func_name = 'on_change_fashion'
			data.fashion_id = FashionID
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		end
    end
	
	local function BuyFashionIntoMall()
		 UIManager.UnloadView(ViewAssets.RoleappearanceUI)
		 --UIManager.PushView(ViewAssets.MallUI) 
		 UIManager.GetCtrl(ViewAssets.MallUI).preAssetUI = ViewAssets.RoleappearanceUI
		 UIManager.GetCtrl(ViewAssets.MallUI).OpenUI()
    end
	
	function IsInFilterTypes(value)
	  for k,v in ipairs(FilterTypes) do
		  if v == value then
		    return true
		  end
	   end
	  return false
    end

	 local IsEquipByType = function(data)
        if IsInFilterTypes(data.Type) then
            FashionId = tonumber(data.Para1)
			if  growingFashion.Fashion[FashionId] and (growingFashion.Fashion[FashionId].Gender == constant.PLAYER_SEX_NAME_TO_INDEX.both or growingFashion.Fashion[FashionId].Gender == MyHeroManager.heroData.sex) 
				and FashiongItemList[data.ID]== nil then
				 for _,id in pairs(growingFashion.Fashion[FashionId].Faction) do
					if id == MyHeroManager.heroData.vocation then return true end
				 end
			end
        end
        return false
    end
	
	local IDSort = function(p1,p2)
           if (FashiongItemList[p1].bUsed and FashiongItemList[p2].bUsed) or (FashiongItemList[p1].bUsed == false and FashiongItemList[p2].bUsed == false )then
		      return FashiongItemList[p1].ItemID < FashiongItemList[p2].ItemID
		  elseif FashiongItemList[p1].bUsed == false and FashiongItemList[p2].bUsed then
			  return false
		  elseif FashiongItemList[p1].bUsed and FashiongItemList[p2].bUsed == false then
			  return true
		  end 
    end
	
	local function ChangeFashionData()
		self.view.iconequipment:SetActive(true)
		for _,Item in pairs(FashiongItemList) do
			if Item.gameObject ~= nil then
			   GameObject.Destroy(Item.gameObject)
			   Item.gameObject = nil
			end
		end

		for _,id in pairs(FashiongIDList) do
	        if IsInFilterTypes(FashiongItemList[id].type) then
				local clone = GameObject.Instantiate(self.view.iconequipment)
				roleItem = clone:GetComponent("LuaBehaviour").luaTable
				roleItem.bTakeup = FashiongItemList[id].bTakeup
				roleItem.SetData(id,FashiongItemList[id].Suitdata)
				clone.transform:SetParent(self.view.MaterialScrollViewContent.transform,false)
				FashiongItemList[id] = roleItem
			end
		  end
		 self.view.iconequipment:SetActive(false)
		
	end
	

	self.InitFashionData = function(data)
		local HeadFashionId = data.appearance[constant.TYPE_HEAD_FASHION]
		local ClothFashionId  = data.appearance[constant.TYPE_CLOTH_FASHION]
		local WeaponId  = data.appearance[constant.TYPE_WEAPON_FASHION]
        LuaUIUtil.ChangeClothes(self.rolemodel,HeadFashionId,ClothFashionId)
		LuaUIUtil.ChangeWeapon(MyHeroManager.heroData.vocation,MyHeroManager.heroData.sex,self.rolemodel,WeaponId)
		for _,Item in pairs(FashiongItemList) do
			if Item.gameObject ~= nil then
			   GameObject.Destroy(Item.gameObject)
			   Item.gameObject = nil
			end
		end
		self.view.iconequipment:SetActive(true)
		FashiongItemList = {}
		FashiongIDList = {}
		for fashionid,suit in pairs(data.fashion_inventory) do  --加载使用过的套装
			local clone = GameObject.Instantiate(self.view.iconequipment)
			roleItem = clone:GetComponent("LuaBehaviour").luaTable
			local item_id =  dressTable[fashionid].ItemID
			if fashionid == HeadFashionId or fashionid == ClothFashionId or fashionid == WeaponId then
				roleItem.bTakeup = true
			end
			roleItem.SetData(item_id,suit)
            clone.transform:SetParent(self.view.MaterialScrollViewContent.transform,false)
			FashiongItemList[item_id] = roleItem
			
			table.insert(FashiongIDList,item_id)
		 end
		
		local ids = BagManager.GetItemIdsBySelector(IsEquipByType)
		for _,id in pairs(ids) do
			local clone = GameObject.Instantiate(self.view.iconequipment)
			roleItem = clone:GetComponent("LuaBehaviour").luaTable
			roleItem.SetData(id)
            clone.transform:SetParent(self.view.MaterialScrollViewContent.transform,false)
			FashiongItemList[id] = roleItem
			table.insert(FashiongIDList,id)
		end
		 
		table.sort(FashiongIDList,IDSort)
		self.view.iconequipment:SetActive(false)
		if ClothFashionId == nil then return end
		local itemid = dressTable[ClothFashionId].ItemID
		FashiongItemList[itemid].goSelect:SetActive(true)
		self.ShowSelItemData(itemid,ClothFashionId) -- 默认显示当前的时装
		ChangeFashionData()
	end
		
	local function OnOrnamentClick()
		if FilterTypes[4] == -1 then
			FilterTypes[4] = constant.TYPE_ORNAMENT_FASHION
			self.view['imgNotshow' .. 4]:SetActive(false)
		else
		    FilterTypes[4] = -1
			self.view['imgNotshow' .. 4]:SetActive(true)
		end
		ChangeFashionData()
	end
	
	local function OnWeaponClick()
		if FilterTypes[3] == -1 then
			FilterTypes[3] = constant.TYPE_WEAPON_FASHION
			self.view['imgNotshow' .. 3]:SetActive(false)
		else
    	   FilterTypes[3] = -1
		   self.view['imgNotshow' .. 3]:SetActive(true)
		end
		ChangeFashionData()
    end
	
	local function OnClothClick()
		if FilterTypes[2] == -1 then
			FilterTypes[2] = constant.TYPE_CLOTH_FASHION
			self.view['imgNotshow' .. 2]:SetActive(false)
		else
		    FilterTypes[2] = -1
			self.view['imgNotshow' .. 2]:SetActive(true)
		end
		ChangeFashionData()
    end
	
	local function OnHeadClick()
		if FilterTypes[1] == -1 then
			FilterTypes[1] = constant.TYPE_HEAD_FASHION
			self.view['imgNotshow' .. 1]:SetActive(false)
		else
		    FilterTypes[1] = -1
			self.view['imgNotshow' .. 1]:SetActive(true)
		end
		ChangeFashionData()
    end
		
	self.ShowSelItemData = function(id,fashionId)
		 if FashiongItemList[id].bUsed == false then
			if BagManager.GetItemNumberById(id) < 1  then
				self.btnTitletxt.text = texttable.UIText[1135016].NR
				ClickEventListener.Get(self.view.btn_buySave).onClick = BuyFashionIntoMall
			else
			    self.btnTitletxt.text = texttable.UIText[1135018].NR
				ClickEventListener.Get(self.view.btn_buySave).onClick = OnCloseUI
			end
			self.view.TxtFashionTime:SetActive(false)
			self.view.Label_Time:SetActive(false)
		  end
		 if ItemID == id then return end
		 if ItemID ~= -1  and FashiongItemList[ItemID] and FashiongItemList[ItemID].gameObject~= nil then FashiongItemList[ItemID].goSelect:SetActive(false) end
		 ItemID = id
		 FashionID = fashionId
         local item = itemTable.Item[id]
		 para1 = item.Para1
		 self.view.Label_foreverTime:SetActive(false)
		 if id > 0 then
            self.imgIcon.sprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",item.Icon))
            self.imgQuality.sprite = LuaUIUtil.GetItemQuality(id)
			self.IntroTxt.text = LuaUIUtil.GetTextByID(item,'Description')
			self.TitleTxt.text = LuaUIUtil.GetItemName(id)
			if FashiongItemList[id].bUsed then
		      self.view.TxtFashionTime:SetActive(true)
	          self.view.Label_Time:SetActive(true)
			  local leftTime = FashiongItemList[ItemID].Suitdata.expire_time - os.time()
			  local day = leftTime/60/60/24 
			  if day > 30000 then 
			    self.view.TxtFashionTime:SetActive(false)
				self.view.Label_foreverTime:SetActive(true)
				self.view.Label_Time:SetActive(false)
			elseif day < 0 then
			    self.TextFashionTime.text = texttable.UIText[1135049].NR
			elseif day < 1 then
				self.TextFashionTime.text = string.format(texttable.UIText[1135050].NR,math.floor(leftTime/3600),math.floor(leftTime/60)%60)
			else
			   self.TextFashionTime.text = string.format(texttable.UIText[1135051].NR,day)
			end
		    end
		end
		local textchannel = ''
		for i = 1,#dressTable[fashionId].Approach,1 do
			local txtId = dressTable[fashionId].Approach[i]
			textchannel = textchannel .. '     • '..texttable.UIText[txtId].NR
			if i%2 == 0 then
				textchannel = textchannel ..'\n'
			end
		end
		self.Textchannel.text = textchannel
		local dress = Util.GetComponentInChildren(self.rolemodel,'Dress')
		 local cloth,head
		 if dressTable[fashionId].Part == constant.TYPE_CLOTH_FASHION then
			LuaUIUtil.ChangeClothes(self.rolemodel,nil,fashionId)
		 elseif dressTable[fashionId].Part == constant.TYPE_HEAD_FASHION then
			LuaUIUtil.ChangeClothes(self.rolemodel,fashionId,nil)
		elseif dressTable[fashionId].Part == constant.TYPE_WEAPON_FASHION then
			LuaUIUtil.ChangeWeapon(MyHeroManager.heroData.vocation,MyHeroManager.heroData.sex,self.rolemodel,fashionId)
		 end
		if FashiongItemList[id].bUsed then
			self.btnTitletxt.text = texttable.UIText[1135017].NR
			ClickEventListener.Get(self.view.btn_buySave).onClick = SaveHeroFashion
		end
    end
	
	self.onLoad = function()
		ClickEventListener.Get(self.view.com_btnclose3).onClick = OnCloseUI
		self.RemoveRoleModel()
		local HeadFashionId =  SceneManager.GetEntityManager().hero.appearance_1
		local ClothFashionId  = SceneManager.GetEntityManager().hero.appearance_2
		local WeaponFashionId  = SceneManager.GetEntityManager().hero.appearance_3
		 LuaUIUtil.GetHeroModel(MyHeroManager.heroData.vocation,MyHeroManager.heroData.sex,function(obj)
			self.rolemodel = obj
			 self.rolemodel.transform.position = Vector3.New(0,0,0)
		     self.rolemodel.transform.localScale = Vector3.New(0.95,0.95,0.95)
             self.rolemodel.transform:SetParent(self.view.rolemodel.transform,false)
	         local rotationModel = self.rolemodel:GetComponent('RotationModel')
             if not rotationModel then        
               self.rolemodel:AddComponent(typeof(RotationModel))
             end
		end,HeadFashionId,ClothFashionId,WeaponFashionId)
       
		self.imgIcon = self.view.SelIcon:GetComponent("Image")
		self.imgQuality = self.view.SelQuality:GetComponent("Image")
		self.IntroTxt = self.view.IntroTxt:GetComponent("TextMeshProUGUI")
		self.TitleTxt = self.view.TitleTxt:GetComponent("TextMeshProUGUI")
		self.btnTitletxt = self.view.btnTitle:GetComponent("TextMeshProUGUI")
		self.Textchannel = self.view.textchannel:GetComponent("TextMeshProUGUI")
		self.TextFashionTime = self.view.TxtFashionTime:GetComponent("TextMeshProUGUI")
		--ClickEventListener.Get(self.view.btndyeing).onClick = RubbingClick
		self.MaterialListTransform = self.view.AppearanceMaterialList:GetComponent("RectTransform")
		self.Bg4Transform = self.view.bg4:GetComponent("RectTransform")
		ClickEventListener.Get(self.view.back).onClick = OnBackUI
		ClickEventListener.Get(self.view.btnAccessories).onClick = OnOrnamentClick
		ClickEventListener.Get(self.view.btnarms).onClick = OnWeaponClick
		ClickEventListener.Get(self.view.btnLatestfashion).onClick = OnClothClick
		ClickEventListener.Get(self.view.btnHeadportrait).onClick = OnHeadClick
		UIUtil.AddButtonEffect(self.view.back, nil, nil)
		UIUtil.AddButtonEffect(self.view.com_btnclose3, nil, nil)
		UIUtil.AddButtonEffect(self.view.btn_buySave, nil, nil)

		FilterTypes = {constant.TYPE_HEAD_FASHION,constant.TYPE_CLOTH_FASHION,constant.TYPE_WEAPON_FASHION,TYPE_ORNAMENT_FASHION }
		for i=1,4 do
			self.view['imgNotshow' .. i]:SetActive(false)
		end
		MyHeroManager.RequestGetFashion()
	end
	
	self.RemoveRoleModel = function()
		if self.rolemodel then
           RecycleObject(self.rolemodel)
           self.rolemodel = nil
		end
    end
	
	return self
end

return CreateRoleappearanceCtrl()