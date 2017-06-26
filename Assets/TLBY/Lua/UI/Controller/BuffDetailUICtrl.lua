---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

function CreateBuffDetailUICtrl(view)
    local self = CreateObject()
    local timer = nil
    local showBuffs = {}
    
    local UpdateItem = function(item,index)
        local data = showBuffs[index+1]
        local buffIcon = item.transform:FindChild('mask/icon'):GetComponent('Image')
        --local overlay = item.transform:FindChild('buffbox/overlay'):GetComponent('Image')
        local count = item.transform:FindChild('count'):GetComponent('TextMeshProUGUI')
        local name = item.transform:FindChild('name'):GetComponent('TextMeshProUGUI')
        local des = item.transform:FindChild('des'):GetComponent('TextMeshProUGUI')
        local leftTime = item.transform:FindChild('time'):GetComponent('TextMeshProUGUI')
        count.text = data.count
        count.gameObject:SetActive(data.count > 1)
        item.transform:FindChild('countBg').gameObject:SetActive(data.count > 1)
        local color = 'white'
        if data.remain_time<=3 then color = 'red' end
        leftTime.text = string.format('<color=%s>%dS',color,math.ceil(data.remain_time))
        name.text = LuaUIUtil.GetTextByID(data.buff_data,'Name')
        des.text = SkillAPI.GetBuffDescription(data.buff_id, data.level)
        buffIcon.overrideSprite = ResourceManager.LoadSprite(data.Icon)
    end
    
    local Create = function()        
        view.buffScrollView:GetComponent('UIMultiScroller'):Init(view.buffUIItem,330,90,0,6,1)
        view.buffUIItem:SetActive(false)
        self.ShowPanel(false)
    end
    
    self.ShowPanel = function(show)
        if show then
            local noBuff = true
            local hero = SceneManager.GetEntityManager().hero
            if hero then
                for _,v in pairs(hero.skillManager.buffs) do
                    if v.Icon then
                        noBuff = false
                        break
                    end
                end
            end
            if noBuff then return end
        end 
      
        view.buffDetailUI:SetActive(show)
        view.buffPanelClose:SetActive(show)
        if show and timer == nil then
            timer = Timer.Repeat(0.2, self.Update)           
        elseif not show and timer ~= nil then
            Timer.Remove(timer)
            timer = nil
        end
    end
    
    self.Update = function()
        showBuffs = {}
        local hero = SceneManager.GetEntityManager().hero
        if hero then
            for _,v in pairs(hero.skillManager.buffs) do
                if v.Icon then
                    table.insert(showBuffs,v)
                end
            end
            table.sort(showBuffs,function(a,b) return a.IconPRI > b.IconPRI end)
        end
        view.buffScrollView:GetComponent('UIMultiScroller'):UpdateData(#showBuffs,UpdateItem)
    end

	self.onUnload = function()
        self.ShowPanel(false)
	end
	
    Create()
	return self
end

