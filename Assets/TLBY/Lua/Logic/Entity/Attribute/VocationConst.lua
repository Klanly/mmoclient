--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/9/30 0030
-- Time: 10:56
-- To change this template use File | Settings | File Templates.
--

require "Common/basic/LuaObject"
local texttable = require "Logic/Scheme/common_char_chinese"

local function CreateVocationConst()
    local self = CreateObject()
    --剑客
    self.SWORDMAN = 1
    --拳师
    self.BOXER = 2
    --巫师
    self.NECROMANCER = 3
    --箭师
    self.ARCHER = 4

    self.GetVocationNameByType = function(type)
        if type == self.SWORDMAN then
            return texttable.UIText[1114050].NR
        elseif  type == self.BOXER then
            return texttable.UIText[1114051].NR
        elseif  type == self.NECROMANCER then
            return texttable.UIText[1114052].NR
        elseif  type == self.ARCHER then
            return texttable.UIText[1114053].NR
        end
        return texttable.UIText[1114056].NR
    end

    self.GetVocationNameByTypes = function(types)
        local result = ""
        local first = true
        for k,v in pairs(types) do
            if not first then
                result = result..","
            end
            first = false
            result = result..self.GetVocationNameByType(v)
        end
        return result
    end

    return self
end

VocationConst = VocationConst or CreateVocationConst()