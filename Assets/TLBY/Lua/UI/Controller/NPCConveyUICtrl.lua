require "UI/Controller/LuaCtrlBase"

local function CreateNPCConveyUICtrl()
    local self = CreateCtrlBase()
    local config = GetConfig('common_npc').TransportNPC   
    self.onLoad = function(id)
        self.AddClick(self.view.rect,self.close)
        
        local dataList ={}
        for k,v in pairs(config) do
            if v.NPCID == id and (MyHeroManager.heroData.country == v.Camp or v.Camp == 0) then
                table.insert(dataList,v)
            end
        end
        for i=1,4 do           
            self.view['btn'..i]:SetActive(false)
            if #dataList >= i then
                self.view['costDes'..i]:GetComponent('TextMeshProUGUI').text = dataList[i].Text
                self.view['name'..i]:GetComponent('TextMeshProUGUI').text = dataList[i].Text
                if #dataList[i].Cost == 2 then
                    self.view['costNum'..i]:GetComponent('TextMeshProUGUI').text = dataList[i].Cost[2]
                    self.view['costIcon'..i]:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(dataList[i].Cost[1])
                end
                self.view['name'..i]:SetActive(#dataList[i].Cost ~= 2)
                self.view['costDes'..i]:SetActive(#dataList[i].Cost == 2) 
                
                self.AddClick(self.view['btn'..i],function()                     
                    local data = {}
                    data.func_name = 'on_npc_transport'
                    data.id = dataList[i].ID
                    MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
                    self.close()
                end)
                self.view['btn'..i]:SetActive(true)
            end
        end
        self.view.btn5:SetActive(true)
        self.view.name5:GetComponent('TextMeshProUGUI').text = '哪也不去'
        self.view.costDes5:SetActive(true)
        self.view.costDes5:SetActive(false) 
        self.AddClick(self.view.btn5,self.close)
    end

    
    return self
end

return CreateNPCConveyUICtrl()


