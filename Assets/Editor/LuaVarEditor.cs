using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using LuaInterface;
using System.Reflection;
using System.IO;

public class LuaVarEditor: EditorWindow
{
    void Update()
    {
        if (!Application.isPlaying)
        {
            return;
        }
              
    }
    LuaTable luaTable = null;
    string applyStr = "";
    string input = "local sceneTable = require'Logic/Scheme/common_scene' local tableData = SceneManager.GetCurSceneData() return sceneTable.TotalScene[tableData.SceneID]";
    void OnGUI()
    {
        if (!Application.isPlaying) return;
        input = EditorGUILayout.TextField("lua代码",input);
        
        if (GUILayout.Button("Apply", EditorStyles.miniButton))
        {
            applyStr = input;
        }
        var outstr = (AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua).CallFunction("loadstring", input))[0] as LuaFunction;
        luaTable = outstr.Call(0)[0] as LuaTable;
        if (luaTable != null)
        {
            foreach (var item in luaTable.ToDictTable())
            {
                if (item.Value.GetType().Name == typeof(System.String).Name)
                {
                    luaTable[item.Key as string] = EditorGUILayout.TextField(item.Key.ToString(), item.Value as string);
                }
                if (item.Value.GetType().Name == typeof(System.Double).Name)
                {
                    luaTable[item.Key as string] = EditorGUILayout.DoubleField(item.Key.ToString(), (double)item.Value);
                }
            }
        }
    }

    [MenuItem("DesignTools/Lua变量编辑")]
    public static void DoWindow()
    {
        GetWindow<LuaVarEditor>("Lua变量编辑");
    }
}

