using UnityEngine;
using System.Collections.Generic;
using LuaInterface;

public class SkillParam : MonoBehaviour
{

    public Dictionary<object, Dictionary<object, object>> paramList = new Dictionary<object, Dictionary<object, object>>();
    LuaTable skills
    {
        get
        {
            var pb = GetComponent<PuppetBehavior>();
            if (pb == null) return null;
            LuaTable pTable = Util.CallMethod("EntityManager", "GetPuppet", pb.uid)[0] as LuaTable;
            var skillManager = pTable["skillManager"] as LuaTable;
            return skillManager["skills"] as LuaTable;
        }
    }
    LuaTable behaviours
    {
        get
        {
            var pb = GetComponent<PuppetBehavior>();
            if (pb == null) return null;
            LuaTable pTable = Util.CallMethod("EntityManager", "GetPuppet", pb.uid)[0] as LuaTable;
            var skillManager = pTable["skillManager"] as LuaTable;
            return skillManager["skilleffects"] as LuaTable;
        }
    }
    void Start ()
    {
        ReadFromParam();
    }

    public void WriteToLuaParam()
    {
        foreach (var param in paramList)
        {
            foreach (var item in param.Value)
            {
                object skillTable = GetTable(skills, param.Key);
                if (skillTable != null)
                {
                    var paramTable = (skillTable as LuaTable)["param"];
                    if(paramTable != null)
                    {
                        SetTable(paramTable as LuaTable, item.Key, item.Value);
                    }
                }
            }
        }
    }

    object GetTable(LuaTable lt, object key)
    {
        if (key.GetType() == typeof(double) || key.GetType() == typeof(int) || key.GetType() == typeof(float))
        {
            double d = (double)key;
            return lt[(int)d];
        }
        else if (key.GetType() == typeof(string))
        {
            return lt[(string)key];
        }
        return null;
    }

    void SetTable(LuaTable lt, object key, object value)
    {
        if (key.GetType() == typeof(double) || key.GetType() == typeof(int) || key.GetType() == typeof(float))
        {
            lt[(int)key] = value;
        }
        else if (key.GetType() == typeof(string))
        {
            lt[(string)key] = value;//索引表格错误
        }
    }


    public void ReadFromParam()
    {
        var skillsTable = skills.ToDictTable();
        paramList = new Dictionary<object, Dictionary<object, object>>();
        foreach (var item in skillsTable)
        {
            var paramTable = (item.Value as LuaTable)["param"];
            if(paramTable != null)
            {
                var paramDict = (paramTable as LuaTable).ToDictTable();
                var dict = new Dictionary<object, object>();
                foreach (var param in paramDict)
                {
                    dict.Add(param.Key, param.Value);
                }
                paramList.Add(item.Key, dict);
            }
        }
    }
}
