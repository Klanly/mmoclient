
--美术资源表
artResourceScheme = require "Logic/Scheme/common_art_resource"
--挑战_主线副本表
challengeMainDungeonScheme = require "Logic/Scheme/challenge_main_dungeon"
--宠物养成表
GrowingPet = require "Logic/Scheme/growing_pet"
--通用_参数公式
commonParameterFormula = require "Logic/Scheme/common_parameter_formula"
--通用战斗基础
commonFightBase = require "Logic/Scheme/common_fight_base"
--通用场景
commonScene = require "Logic/Scheme/common_scene"
--系统登录数据
systemLoginCreate = require "Logic/Scheme/system_login_create"
--通用物品
commonItem = require "Logic/Scheme/common_item"
--通用协议
constant = require "Common/constant"
--养成技能
growingSkillScheme = require "Logic/Scheme/growing_skill"
--pvp阵营
pvpCamp = require "Logic/Scheme/pvp_country"
--通用文字中文
commonCharChinese = require "Logic/Scheme/common_char_chinese"

function GetConfig(name)
	return require ("Logic/Scheme/" .. name)
end