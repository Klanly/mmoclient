using UnityEngine;
using System.Collections.Generic;
using UnityEditor;

public class CreateDressPartPrefab : EditorWindow
{
    GameObject original;

    [MenuItem("DesignTools/提取套装部件")]
    public static void OpenAvtarWindow()
    {
        //CreateDressPartPrefab window = (CreateDressPartPrefab)EditorWindow.GetWindow(typeof(CreateDressPartPrefab));
        //window.Show();

        for (int i = 0; i < Selection.gameObjects.Length; i++)
        {
            Create(Selection.gameObjects[i]);
        }
    }

    void OnGUI()
    {
        original = EditorGUILayout.ObjectField(new GUIContent("含有套装部件的Prefab"), original, typeof(GameObject),true) as GameObject;

        if (GUILayout.Button("Create"))
        {
            Create(original);
        }
    }

    static void Create(GameObject original)
    {
        var pres = original.GetComponentsInChildren<SkinnedMeshRenderer>(true);
        for (int j = 0; j < pres.Length; j++)
        {
            GameObject go = new GameObject();
            go.name = pres[j].name;
            var cp = go.AddComponent<DressPart>();

            List<string> bonesName = new List<string>();
            for (int i = 0; i < pres[j].bones.Length; i++)
            {
                bonesName.Add(pres[j].bones[i].name);
            }

            cp.skinMeshInfo = new global::SkinMeshInfo();
            cp.skinMeshInfo.mesh = pres[j].sharedMesh;
            cp.skinMeshInfo.materials = new List<Material>();
            cp.skinMeshInfo.bonesName = bonesName;
            for (int i = 0; i < pres[j].sharedMaterials.Length; i++)
            {
                cp.skinMeshInfo.materials.Add(pres[j].sharedMaterials[i]);
            }
            string prefabPath = string.Format("Assets/Resources/Character/Hero/{0}_{1}.prefab", original.name, pres[j].name);
            Object prefab = PrefabUtility.CreateEmptyPrefab(prefabPath);
            PrefabUtility.ReplacePrefab(go, prefab, ReplacePrefabOptions.ConnectToPrefab);
            DestroyImmediate(go);
        }
    }
}