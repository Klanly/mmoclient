--huasong--
require "Common/basic/LuaObject"

CreateRepeatItemList = function()
    local self = CreateObject()
    local sortKeyList = {}
    local itemList = {}
    local goItem = nil
    local tfContainer = nil
    
    self.GetItemCount = function()
        return #itemList
    end
    
    self.GetItem = function(index)
        return itemList[index]
    end
    
    self.GetIndexByKey = function(key)
        for i=1,#sortKeyList do
            if sortKeyList[i] == key then
                return i
            end
        end
    end
    
    self.GetKeyByIndex = function(index)
        return sortKeyList[index]
    end
    
    self.GetItemByKey = function(key)
        for i=1,#sortKeyList do
            if sortKeyList[i] == key then
                return self.GetItem(i)
            end
        end
        print("error key "..key.." invaild")
        return nil
    end
    
    self.Init = function(itemGameObject,containerTransform)
        goItem = itemGameObject
        tfContainer = containerTransform
    end
    
    self.BindList = function(dataList ,func ,sortFunc)--func(index,key)index:列表的位置 key:dataList的key
        sortKeyList = {}
        if sortFunc == nil then         
            local index = 0
            for k,v in pairs(dataList) do
                index = index+1
                sortKeyList[index] = k
            end
        else
            sortFunc(sortKeyList)
        end
        
        goItem:SetActive(true)
        local index = 1
        for i=1,#sortKeyList do
            if itemList[i] == nil then
                local clone = GameObject.Instantiate(goItem)
                clone.transform:SetParent(tfContainer,false)
                itemList[i] = clone
            end
            func(i,sortKeyList[i])
            index = index+1
        end
        for i = #itemList ,index,-1 do
            GameObject.Destroy(itemList[i])
            itemList[i] = nil
        end
        goItem:SetActive(false)
    end

    
    self.Destroy = function()
        for i = #itemList ,1 ,-1 do
            GameObject.Destroy(itemList[i])
        end
        itemList = {}
    end
    
    return self
end