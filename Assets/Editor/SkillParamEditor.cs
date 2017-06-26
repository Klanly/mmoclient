using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using System.Collections;
using System.Reflection;
using System.Collections.Generic;
using UnityEditor.SceneManagement;

[CustomEditor(typeof(SkillParam))]
public class SkillParamEditor : Editor
{
    SkillParam script { get { return target as SkillParam; } }
    public Dictionary<object, bool> foldDict = new Dictionary<object, bool>();
    public override void OnInspectorGUI()
    {
        var paramList = new Dictionary<object, Dictionary<object, object>>();
        foreach (var k in script.paramList.Keys)
        {
            if (!foldDict.ContainsKey(k)) foldDict.Add(k,false);
            foldDict[k] = EditorGUILayout.Foldout(foldDict[k], "Skill Slot ID " + k);
            var dict = new Dictionary<object, object>();
            foreach (var key in script.paramList[k].Keys)
            {
                if (script.paramList[k][key].GetType() == typeof(string))
                {
                    dict.Add(key, foldDict[k] ? EditorGUILayout.TextField(key.ToString(), script.paramList[k][key].ToString()) : script.paramList[k][key].ToString());
                }
                if (script.paramList[k][key].GetType() == typeof(double))
                {
                    dict.Add(key, foldDict[k] ? EditorGUILayout.DoubleField(key.ToString(), (double)(script.paramList[k][key])) : (double)(script.paramList[k][key]));
                }
            }
            paramList.Add(k, dict);
        }
        script.paramList = paramList;
        if (GUILayout.Button("Apply", EditorStyles.miniButton))
        {
            script.WriteToLuaParam();
        }
        if (GUILayout.Button("Load", EditorStyles.miniButton))
        {
            script.ReadFromParam();
        }
    }

    [MenuItem("DesignTools/技能参数编辑")]
    static void Add()
    {
        if (!Application.isPlaying) return;
        if(Selection.activeObject)
        {
            GameObject go = Selection.activeObject as GameObject;
            if (go && go.GetComponent<PuppetBehavior>())
            {
                go.AddComponent<SkillParam>();
            }
        }
    }
}