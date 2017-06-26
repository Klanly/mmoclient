--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/9/20 0020
-- Time: 17:18
-- To change this template use File | Settings | File Templates.
--

require "Common/basic/LuaObject"
require "math"
require "Logic/Bag/QualityConst"
require "UI/Controller/PetUICtrl"
local itemTable = require "Logic/Scheme/common_item"
local texttable = require "Logic/Scheme/common_char_chinese"

local function CreateItemUI()
	local self = CreateViewBase()
    local pos = 1
    local data = nil;
	local ClickHandle

	function self.Awake()
        --品质
        self.imgQuality = self.transform:FindChild("Quality").gameObject:GetComponent("Image")
        self.goQuality = self.transform:FindChild("Quality").gameObject

        --锁
        self.goLock = self.transform:FindChild("Lock").gameObject
        --物品
        self.goIcon = self.transform:FindChild("Icon").gameObject
        self.imgIcon = self.transform:FindChild("Icon").gameObject:GetComponent("Image")
        --数量
		self.number = self.transform:FindChild("Number").gameObject
        self.numberTxt = self.number:GetComponent("TextMeshProUGUI")
        --不可出售
        self.sellFlag = self.transform:FindChild("SellFlag").gameObject
        --出售选中
        self.sellSelect = self.transform:FindChild("SellSelect").gameObject
        --选中
        self.goSelect = self.transform:FindChild("Select").gameObject
		--
		self.needItems = self.transform:FindChild("Need").gameObject
		--拥有材料数量
		self.ownerNum = self.needItems.transform:FindChild("OwnerNum").gameObject:GetComponent("TextMeshProUGUI")
		--需要材料数量
		--self.needNum = self.needItems.transform:FindChild("NeedNum").gameObject:GetComponent("TextMeshProUGUI")
		
        ClickEventListener.Get(self.goIcon).onClick = self.OnClick
        ClickEventListener.Get(self.sellFlag).onClick = self.OnNotSell
        ClickEventListener.Get(self.goLock).onClick = self.OnLockClick
    end

    function self.OnClick()
		if (ClickHandle) then
		
			ClickHandle(data)
		end
    end

    self.OnNotSell = function()
        if not UIManager.GetCtrl(ViewAssets.PromptUI).isLoaded then
            UIManager.PushView(ViewAssets.PromptUI)
        end
        UIManager.GetCtrl(ViewAssets.PromptUI).UpdateMsg(texttable.UIText[1101039].NR)
    end

    self.OnLockClick = function()

    end

    self.SetPos = function(inpos,offset)
        local vpos = Vector3.New(-286 + ((inpos - 1) % 5) * 145,offset - 80 - math.floor((inpos - 1) / 5) * 145,0)
        self.transform.anchoredPosition3D=vpos
        self.goIcon:SetActive(false)
        self.goLock:SetActive(false)
        self.goQuality:SetActive(false)
        self.sellFlag:SetActive(false)
        self.sellSelect:SetActive(false)
    end

    self.SetData = function(indata)
        data = indata
		ClickHandle = data.ClickHandle
        if data.unlock < data.pos then
            self.goLock:SetActive(true)
        else
            self.goLock:SetActive(false)
        end

        local item = itemTable.Item[data.id]

        if data.id > 0 then
            self.goIcon:SetActive(true)
            self.imgIcon.overrideSprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",item.Icon))
			
			if data.count == 0 then
			
				self.imgIcon.material = UIGrayMaterial.GetUIGrayMaterial()
			elseif data.count >= 1 then
			
				self.imgIcon.material = nil
			end

           	self.goQuality:SetActive(true)
          	self.imgQuality.overrideSprite = LuaUIUtil.GetItemQuality(data.id)

            self.numberTxt.text = data.count

                self.sellFlag:SetActive(false)
                self.sellSelect:SetActive(false)
                if data.select then
                    self.goSelect:SetActive(true)
					
					if (data.isNeedNum and data.GetNeedNum) then
					
						local needCount = data.GetNeedNum(data)
						self.needItems:SetActive(true)
						local owenerNumColor = '<color="green">'
						if (data.count < needCount) then
						
							owenerNumColor = '<color="red">'
						end
						self.ownerNum.text = owenerNumColor..data.count..'<color="white">'..'/'..needCount
						self.number:SetActive(false)
					end
                else
                    self.goSelect:SetActive(false)
					self.needItems:SetActive(false)
					self.number:SetActive(true)
                end
            --end

        else
            self.goQuality:SetActive(false)
            self.goIcon:SetActive(false)
            self.numberTxt.text = ""
            self.sellFlag:SetActive(false)
            self.sellSelect:SetActive(false)
            self.goSelect:SetActive(false)
        end

    end 

	return self
end

return CreateItemUI()

