using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using TMPro;
using System.Text.RegularExpressions;
using System.Linq;

class ResourceBatchEdit
{
    private static GameObject LoadAssetAtPathAndInstantiatePrefab(string prefab_path)
    {
        Object prefab_obj = AssetDatabase.LoadAssetAtPath(prefab_path, typeof(GameObject));
        //Object prefab_obj = AssetDatabase.LoadMainAssetAtPath(prefab_path);
        if (prefab_obj == null)
        {
            Debug.LogError("LoadAssetAtPath: " + prefab_path + " is null");
            return null;
        }

        GameObject go = PrefabUtility.InstantiatePrefab(prefab_obj) as GameObject;
        if (go == null)
        {
            Debug.LogError("InstantiatePrefab: " + prefab_obj + " is null");
            return null;
        }

        return go;
    }

    public static List<string> GetFiles(string root_path, string suffix = ".prefab")
    {
        List<string> results = new List<string>();

        string[] files = Directory.GetFiles(root_path);

        foreach (string file in files)
        {
            if (file.EndsWith(".meta"))
                continue;

            if (file.EndsWith(suffix))
                results.Add(file.Replace("\\", "/"));
        }

        string[] sub_dirs = Directory.GetDirectories(root_path);
        foreach (string sub_dir in sub_dirs)
        {
            results.AddRange(GetFiles(sub_dir.Replace("\\", "/")));
        }

        return results;
    }

    static List<T> GetComponentsInChildren<T>(GameObject go)
    {
        var list = new List<T>();
        var com = go.GetComponent<T>();
        if (com != null) list.Add(com);
        for (int i = 0; i < go.transform.childCount; i++)
        {
            list.AddRange(GetComponentsInChildren<T>(go.transform.GetChild(i).gameObject));
        }
        return list;
    }
    [MenuItem("DesignTools/ReplaceOneFont")]
    public static void ReplaceOneFont()
    {
        if (Selection.activeGameObject == null) return;
        var texts = GetComponentsInChildren<TextMeshProUGUI>(Selection.activeGameObject);
        var simli = AssetDatabase.LoadAssetAtPath<TMP_FontAsset>("Assets/Resources/FontAssets/Fonts & Materials/SIMLI SDF.asset");
        var dsfs = AssetDatabase.LoadAssetAtPath<TMP_FontAsset>("Assets/Resources/FontAssets/Fonts & Materials/Droid Sans Fallback SDF.asset");
        var simlio = AssetDatabase.LoadMainAssetAtPath("Assets/Resources/FontAssets/Fonts & Materials/SIMLI SDF - Outline.mat") as Material;
        var dsfso = AssetDatabase.LoadMainAssetAtPath("Assets/Resources/Materials/Fonts/Droid Sans Fallback SDF - Outline.mat") as Material;
        for (int i = 0; i < texts.Count; i++)
        {
            var tmp = texts[i];
            var fontName = texts[i].font.name;
            var size = texts[i].fontSize;
            var outLine = tmp.fontSharedMaterial && tmp.fontSharedMaterial.name == "Droid Sans Fallback SDF - Outline";
            if (fontName == "Droid Sans Fallback SDF" && outLine && size == 53)
            {

                tmp.fontSize = 45;
            }
        }
    }

    [MenuItem("DesignTools/ReplaceFont")]
    public static void ReplaceFont()
    {
        if (Selection.activeGameObject == null) return;
        var texts = GetComponentsInChildren<Text>(Selection.activeGameObject);
        var simli = AssetDatabase.LoadAssetAtPath<TMP_FontAsset>("Assets/Resources/FontAssets/Fonts & Materials/SIMLI SDF.asset");
        var dsfs = AssetDatabase.LoadAssetAtPath<TMP_FontAsset>("Assets/Resources/FontAssets/Fonts & Materials/Droid Sans Fallback SDF.asset");
        var simlio = AssetDatabase.LoadMainAssetAtPath("Assets/Resources/FontAssets/Fonts & Materials/SIMLI SDF - Outline.mat") as Material;
        var dsfso= AssetDatabase.LoadMainAssetAtPath("Assets/Resources/FontAssets/Fonts & Materials/Droid Sans Fallback SDF - Outline.mat") as Material;

        for (int i = 0; i < texts.Count; i++)
        {
            var obj = texts[i].gameObject;
            var outline = obj.GetComponent<Outline>();
            var fontName = texts[i].font.name;
            var color = texts[i].color;
            var size = texts[i].fontSize;
            //var size = texts[i].text;
            var alignment = (int)texts[i].alignment;
            var text = texts[i].text;
            GameObject.DestroyImmediate(texts[i]);
            var tmp = obj.AddComponent<TextMeshProUGUI>();
            tmp.color = color;
            tmp.fontSize = size;
            tmp.text = text;
            if (alignment > 5) alignment = alignment + 2;
            else if (alignment > 2) alignment = alignment + 1;
            tmp.alignment = (TextAlignmentOptions)alignment;

            if (fontName == "simhei")
            {
                tmp.font = dsfs;
            }
            else
            {
                tmp.font = simli;
            }

            if (outline)
            {
                var outlineColor = outline.effectColor;
                GameObject.DestroyImmediate(outline);
                if (tmp.font == simli) tmp.fontSharedMaterial = simlio;
                if (tmp.font == dsfs) tmp.fontSharedMaterial = dsfso;
                //tmp.outlineColor = outlineColor;
            }
            tmp.raycastTarget = false;
        }
    }
}