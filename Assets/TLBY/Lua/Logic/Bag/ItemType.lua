--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/9/23 0023
-- Time: 15:44
-- To change this template use File | Settings | File Templates.
--

require "Common/basic/LuaObject"
local itemtable = require "Logic/Scheme/common_item"
local texttable = require "Logic/Scheme/common_char_chinese"
local itemconfig = itemtable.Item
local uitext = texttable.UIText
local const = require "Common/constant"

local function CreateItemType()
    local self = CreateObject()
    --是否装备类型
    self.IsEquipByType = function(data)
        if data == const.TYPE_WEAPON or data == const.TYPE_NECKLACE or data == const.TYPE_RING or data == const.TYPE_HELMET or data == const.TYPE_ARMOR or data == const.TYPE_BELT or data == const.TYPE_LEGGING or data == const.TYPE_BOOT then
            return true
        end
        return false
    end

    --是否装备类型
    self.IsEquipById = function(data)
        local itemdata = itemconfig[data]
        if itemdata then
            return self.IsEquipByType(itemdata.Type)
        end
        return false
    end

    --获得装备类型文字
    self.GetEquipPartNameByType = function(data)
        if not self.IsEquipByType(data) then
            return ""
        end
        if data == const.TYPE_WEAPON then
            return uitext[1114064].NR
        elseif data == const.TYPE_NECKLACE then
            return uitext[1114065].NR
        elseif data == const.TYPE_RING then
            return uitext[1114066].NR
        elseif data == const.TYPE_HELMET then
            return uitext[1114067].NR
        elseif data == const.TYPE_ARMOR then
            return uitext[1114068].NR
        elseif data == const.TYPE_BELT then
            return uitext[1114069].NR
        elseif data == const.TYPE_LEGGING then
            return uitext[1114070].NR
        elseif data == const.TYPE_BOOT then
            return uitext[1114071].NR
        end
        return ""
    end

    return self
end

ItemType = ItemType or CreateItemType()