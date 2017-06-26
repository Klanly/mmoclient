using UnityEngine;
using System.Collections;

public class DynamLoadRes : MonoBehaviour {

    public string resUrl = string.Empty;
    private GameObject instance = null;
    private bool bLoaded = false;

    void Awake()
    {
        AppFacade.Instance.gameManager.CullGroup.RegisterObject(transform);
    }

    public void LoadRes()
    {
        if (bLoaded) return;  // 防止重复加载
        bLoaded = true;
        ObjectPoolManager.NewObject(resUrl, EResType.eSceneLoadRes, (obj) =>
            {
                instance = obj as GameObject;
            });
    }

    public void UnLoadRes()
    {
        if (instance && bLoaded)
        {
            ObjectPoolManager.RecycleObject(instance);
            bLoaded = false;
        }

    }

    void OnDestroy()
    {
        if (instance != null)
        {
            GameObject.Destroy(instance);
            instance = null;
        }
    }

#if UNITY_EDITOR
    void OnDrawGizmos()
    {
        UnityEditor.Handles.color = Color.red;
        UnityEditor.Handles.CircleCap(0, transform.position, Quaternion.AngleAxis(90, Vector3.right), 18f);
        UnityEditor.Handles.color = Color.green;
        string name = string.Empty;
        if (resUrl.Contains("/"))
        {
            int i = resUrl.LastIndexOf('/');
            name = resUrl.Substring(i+1);
        }
        UnityEditor.Handles.Label(transform.position, name);

    }
#endif
}
