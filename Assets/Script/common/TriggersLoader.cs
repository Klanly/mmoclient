/********************************************************************************
** auth： 张增
** date： 2016/09/8
** desc： 加载触发器
*********************************************************************************/
using UnityEngine;
using LuaInterface;


public class TriggersLoader
{
    static public LuaTable luaTable { get; private set; }

    static public void LoaderLua(string fullPath)
    {
        string className = System.IO.Path.GetFileNameWithoutExtension(fullPath);
        LuaManager luaManager = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
        luaTable = luaManager.GetTable(className);
        if (luaTable == null)
        {
            luaManager.DoFile(fullPath);
            if (!string.IsNullOrEmpty(className))
            {
                luaTable = luaManager.GetTable(className);
                if (luaTable == null)
                {
                    Util.LogError("Game", string.Format("没有找到{0}对应的lua表, 请确保文件名和lua表名一致", className));
                }
            }
        }
    }

    static public void OnCall(string luaName, string func, params object[] args)
    {
        if (luaTable == null)
        {
            //LoaderLua("Logic/Common/TriggersManager.lua");
            LoaderLua(luaName);
        }

        if (luaTable != null)
        {
            Util.CallMethod(luaTable.name, func, args);
        }
    }
}
