require "UI/Controller/LuaCtrlBase"

local function CreateSelectTargetUICtrl()
    local self = CreateCtrlBase()
    local CBMoveToNPC = nil
    
    self.onLoad = function(puppetUIDs,CallBack)
        self.AddClick(self.view.rect,self.close)
        
        local ret
        local position
        ret,position = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.view.bg.transform.parent, 
                UnityEngine.Input.mousePosition, CameraManager.uiCamera, 1)
        self.view.bg:GetComponent('RectTransform').anchoredPosition = position
        
        CBMoveToNPC = CallBack
        
        local puppets = {}
        for k,v in pairs(puppetUIDs) do
            local target = SceneManager.GetEntityManager().GetPuppet(v)
            if target then
                table.insert(puppets,target)
            end
        end
        table.sort(puppets,function(a,b) return (a.entityType ~= b.entityType and a.entityType == EntityType.NPC) end)
        
        for i=1,5 do
            self.view['btn'..i]:SetActive(false)
            if puppets[i] then
                local color = '#FFFFFF'
                if puppets[i].entityType == EntityType.NPC then
                    color = '#ffb40a'
                end
                self.view['name'..i]:GetComponent('TextMeshProUGUI').text = string.format('<color=%s>%s',color,puppets[i].name)
                self.AddClick(self.view['btn'..i],function() self.SelectPuppet(puppets[i].data.entity_id) end)
                self.view['btn'..i]:SetActive(true)
            end
        end
    end
    
    self.SelectPuppet = function(id)
        self.close()
        local target = SceneManager.GetEntityManager().GetPuppet(id)
        if target then
            TargetManager.SetTarget(target)
            if target and target.entityType == EntityType.NPC then
                DestinationEffect.Moveto(target.behavior.transform.position,3, function() CBMoveToNPC(target) end)
            end
        end
    end
    
    return self
end

return CreateSelectTargetUICtrl()


