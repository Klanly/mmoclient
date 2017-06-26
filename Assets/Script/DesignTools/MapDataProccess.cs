using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class MapDataProccess : MonoBehaviour {

    public MapEditorData allEditorData;
    public static MapDataProccess instance;
    List<MeshCollider> meshColliders = new List<MeshCollider>();
    SortedList<int, MapResProperty> kResList = new SortedList<int, MapResProperty>();

    public SortedList<int, MapResProperty> ResList
    {
        get { return kResList; }
        set { kResList = value; }
    }

    void Awake()
    {
        LoadData();
        instance = this;
    }

    //载入地图编辑器数据
    private void LoadData()
    {
        UnityEngine.TextAsset s = null;
#if UNITY_EDITOR
         s = UnityEditor.AssetDatabase.LoadAssetAtPath<TextAsset>("Assets/PublishRes/DesignTools/MapEditorData"+ ".json");
        allEditorData = JsonMapper.ToObject<MapEditorData>(s.text);
#endif
    }

    //初始化地形网格数据
    void InitTerrainData()
    {
        var gos = GameObject.FindGameObjectsWithTag("TerrainGeometry");
        meshColliders.Clear();
        for (int i = 0; i < gos.Length; i++)
        {
            var meshCollider = gos[i].GetComponent<MeshCollider>();
            if (meshCollider != null)
                meshColliders.Add(meshCollider);
        }
    }

    public Vector3 GetTerrainPos(Vector3 Dest, bool bMousePt = false)
    {
        Ray ray;
        if (bMousePt)
            ray = Camera.main.ScreenPointToRay(Dest);
        else
        {
            ray = new Ray(Dest, Vector3.down);
        }

        RaycastHit[] hits = Physics.RaycastAll(ray);
        for (int i = 0; i < hits.Length; i++)
        {
            if (hits[i].collider.gameObject.CompareTag("TerrainGeometry"))
                return hits[i].point;
        }
       
        return Vector3.zero;
    }

    public int GetLastID()
    {
        int eid = 0;
        IList<int> ilistValues = MapDataProccess.instance.ResList.Keys;
        int count = MapDataProccess.instance.ResList.Count;
        if (count > 0)
        {
            int LastId = ilistValues[count - 1]; //最后一个元素ID
            eid = MapDataProccess.instance.ResList[LastId].GetEid() + 1;
        }
        return eid;
    }

   
}
