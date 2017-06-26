/********************************************************************************
** auth： Shang Yuzhong
** date： 2016.8.10
** desc： 地图编辑器等工具菜单
*********************************************************************************/

using UnityEngine;
using UnityEditor;
using UnityEngine.EventSystems;

public class MyEditorScript {

    [MenuItem("DesignTools/打开地图编辑")]
    static void OpenMapEditor()
    {
        if (!EditorApplication.isPlaying)
        {
            return;
        }

        Debug.Log("打开地图编辑");
        if (GameObject.Find("MapDesignCanvas"))
        {
            UIDialogMessage.Show("已经添加了地图编辑器");
            return;
        }
            

        if(Camera.main&Camera.main.GetComponent<CameraController>())
        {
            Camera.main.GetComponent<CameraController>().enabled = false;
        }
#if UNITY_EDITOR
        GameObject mapEditor = GameObject.Instantiate(UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>("Assets/PublishRes/DesignTools/MapDesignCanvas"+".prefab"));
#endif
        mapEditor.name = "MapDesignCanvas";
        if (GameObject.Find("EventSystem") == null)
        {
            GameObject go = new GameObject("EventSystem");
            go.AddComponent<EventSystem>();
            go.AddComponent<StandaloneInputModule>();
        }
        
    }
}
