--huasong--
require "Common/basic/LuaObject"
require "Logic/Bag/ItemType"

local function CreateGetDropItemUI( )
    local self = CreateObject()
    local second = 30
    local timer = nil
    local dropEntityID = nil
    local itemtable = require "Logic/Scheme/common_item"
    local equipTable = require 'Logic/Scheme/equipment_base'
    
    local SendGiveup = function()
        local data = {}
        data.drop_entity_id = dropEntityID
        data.is_want = false
        data.func_name = "on_reply_manual_roll"
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        RecycleObject(self.gameObject)
    end
    
    local SendNeed = function()
        local data = {}
        data.drop_entity_id = dropEntityID
        data.is_want = true
        data.func_name = "on_reply_manual_roll"
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        RecycleObject(self.gameObject)
    end
    
    local ShowNeed = function(id)
        if equipTable.equipTemplate[id] then
            local factions = equipTable.equipTemplate[id].Faction
            for i=1,#factions do
                if factions[i] == MyHeroManager.heroData.vocation then
                    return true
                end
            end
            return false
        end
        return true
    end
    
    self.SetData = function(data,number)
        self.count.text = data.count
        self.count.gameObject:SetActive(data.count > 1)
        self.quality.overrideSprite = LuaUIUtil.GetItemQuality(data.item_id)
        self.icon.overrideSprite = LuaUIUtil.GetItemIcon(data.item_id)
        self.textGreed:SetActive(not ShowNeed())
        self.textNeed:SetActive(ShowNeed())        
        dropEntityID = data.id
        self.bg.anchoredPosition = Vector2.New(-730-number*10,130-number*10)
    end
    
    self.CountDown = function()
        if second < 0 then
            SendNeed()
            return
        end
        self.timeLeft.text = second..'S'
        second = second -1
    end
    
    self.Awake = function()
        self.btnGiveup = self.transform:Find('bg/btnGiveup').gameObject
        self.bg = self.transform:Find('bg'):GetComponent('RectTransform')
        self.btnNeed = self.transform:Find('bg/btnNeed').gameObject
        self.textNeed = self.transform:Find('bg/textNeed').gameObject
        self.textGreed = self.transform:Find('bg/textGreed').gameObject
        ClickEventListener.Get(self.btnGiveup).onClick = SendGiveup
        ClickEventListener.Get(self.btnNeed).onClick = SendNeed
        self.timeLeft = self.transform:Find('bg/timeLeft'):GetComponent('TextMeshProUGUI')
        self.quality = self.transform:Find('bg/quality'):GetComponent('Image')
        self.icon = self.transform:Find('bg/icon'):GetComponent('Image')
        self.count = self.transform:Find('bg/count'):GetComponent('TextMeshProUGUI')
    end
    
    self.OnDisable = function()
        if timer then
            Timer.Remove(timer)
            timer = nil
        end
    end
    
    self.OnEnable = function()
       second = 10
       self.CountDown()
       timer = Timer.Repeat(1, self.CountDown)
    end

    return self
end

return CreateGetDropItemUI()