using UnityEngine;
using UnityEditor;
using UnityEngine.SceneManagement;
using System.Collections.Generic;
using System.IO;

public class GenLightmapData : MonoBehaviour {

    [MenuItem("DesignTools/保存预制件的烘焙信息", false, 0)]
    static void SaveLightmapInfoByGameObject()
    {
        foreach (Object obj in Selection.objects)
        {
            if (null == obj) continue;
            GameObject go = obj as GameObject;
            PrefabLightmapData data = go.GetComponent<PrefabLightmapData>();
            if (data == null)
            {
                data = go.AddComponent<PrefabLightmapData>();
            }
            //save lightmapdata info by mesh.render
            data.SaveLightmap();
            EditorUtility.SetDirty(go);
            string SceneName = SceneManager.GetActiveScene().name;

            if (SceneName.Contains("_"))
            {
                int i = SceneName.LastIndexOf('_');
                SceneName = SceneName.Substring(0, i);
            }

            string prefabpath = "Assets/Resources/SceneLoadRes/" + SceneName + "/";
            if (!Directory.Exists(prefabpath))
            {
                Directory.CreateDirectory(prefabpath);
            }
            AssetDatabase.Refresh();
            string prefabUrl = prefabpath  + go.name + ".prefab";
            GameObject selGo = GameObject.Instantiate(go);
            selGo.name = go.name;
            selGo.transform.position = go.transform.position;
            go.AddComponent<DynamLoadRes>().resUrl = SceneName + "/" +go.name;
            if (!File.Exists(prefabUrl))
                PrefabUtility.CreatePrefab(prefabUrl, selGo);
            else
            {
                prefabUrl = "SceneLoadRes/" + SceneName + "/" + go.name;
                Object origGo = Resources.Load(prefabUrl);
                PrefabUtility.ReplacePrefab(selGo, origGo, ReplacePrefabOptions.ConnectToPrefab);//PrefabUtility.GetPrefabParent(go)
            }

            DestroyImmediate(selGo);
            DestroyImmediate(data);
            List<GameObject> childList = new List<GameObject>();
            int childCount = go.transform.childCount;
            for (int i = 0; i < childCount; i++)
            {
                GameObject child = go.transform.GetChild(i).gameObject;
                childList.Add(child);
            }
            for (int i = 0; i < childCount; i++)
            {
                DestroyImmediate(childList[i]);
            }
        }
       
        EditorUtility.DisplayDialog("物体烘焙信息", "生成完成", "确定");
        
        //applay prefab
       // PrefabUtility.ReplacePrefab(go, PrefabUtility.GetPrefabParent(go), ReplacePrefabOptions.ConnectToPrefab);
    }
}
