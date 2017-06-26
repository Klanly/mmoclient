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
                if dataList[i].Scene == 1001 then
                    self.view['name'..i]:GetComponent('TextMeshProUGUI').text = '前往帮会领地'       
                elseif #dataList[i].Cost == 2 then
                    local itemName = LuaUIUtil.GetItemName(dataList[i].Cost[1])
                    self.view['name'..i]:GetComponent('TextMeshProUGUI').text = string.format('前往%s（需消耗%s*%d）',dataList[i].Text,itemName,dataList[i].Cost[2])
                else
                    self.view['name'..i]:GetComponent('TextMeshProUGUI').text = '回到主城'
                end
                
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
        self.AddClick(self.view.btn5,self.close)
    end

    
    return self
end

return CreateNPCConveyUICtrl()


