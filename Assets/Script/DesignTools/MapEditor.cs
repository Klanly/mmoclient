/********************************************************************************
** auth： Shang Yuzhong
** date： 2016.8.8
** desc： 地图编辑器
*********************************************************************************/

using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using System.IO;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class MapEditorItem
{
    public float scale;
    public string icon;
    public string resPath;
    public string name;
    public int ID;
    public int triggerType;
    public float triggerRadius;
    public int delayTime;
}

public class MapEditorType
{
    public string name;
    public int type;
    public string icon;
    public List<MapEditorItem> children;
}

public class MapEditorData
{
    public List<MapEditorType> editorData;
}

public class MapItemInstance
{
    public MapEditorItem itemData;
    public GameObject modelObj;
    public GameObject btnObj;
}


public class MapEditor : MonoBehaviour
{
    MapEditorData allEditorData;
    List<MapItemInstance> ownInstanceList;

    // Use this for initialization
    void Start()
    {
        Button exportBtn = GameObject.Find("ExportBtn").GetComponent<Button>();
        Button importBtn = GameObject.Find("ImportBtn").GetComponent<Button>();

        exportBtn.onClick.AddListener(delegate () { OnClickExport(); });
        importBtn.onClick.AddListener(delegate () { OnClickImport(); });

        ownInstanceList = new List<MapItemInstance>();

        LoadData();

        CreateTypePanel();
    }

    void OnClickImport()
    {
        Debug.Log("import");
        TestOpenFile();
    }

    void OnClickExport()
    {
        Debug.Log("export");

        int totalCnt = ownInstanceList.Count;
        Debug.Log(totalCnt);
        string[] csvString = new string[totalCnt + 1];

        csvString[0] = "Name,ID,Scale,PointX,PointY,PointZ";
        int i = 1;
        foreach (MapItemInstance instanceData in ownInstanceList)
        {
            if(i >= totalCnt + 1)
            {
                Debug.Log("Error in OnClickExport: out of range");
            }

            Transform modelTansform = instanceData.modelObj.transform;

            csvString[i] = instanceData.itemData.name + "," + instanceData.itemData.ID + "," + modelTansform.localScale.x + "," +
                modelTansform.localPosition.x + "," + modelTansform.localPosition.y + "," + modelTansform.localPosition.z;
            ++i;
        }

        ExportToFile(csvString);

#if UNITY_EDITOR
        EditorUtility.DisplayDialog("Tips", "导出完成", "ok");
#endif
    }

    void ExportToFile(string[] str)
    {
        string dirName = "/Files";
        string fullDirPath = Application.dataPath + dirName;
        string fullFilePath = fullDirPath + "/file.csv";
        StreamWriter files = null;

        DirectoryInfo myDirectoryInfo = new DirectoryInfo(fullDirPath);

        if (myDirectoryInfo.Exists)
            print("this file already exists!");
        else
        {
            Directory.CreateDirectory(fullDirPath);
            print("create file");
        }

        if (!File.Exists(fullFilePath))
        {
            files = File.CreateText(fullFilePath);
        }
        
        File.WriteAllLines(fullFilePath, str,System.Text.Encoding.UTF8);
    } 

    void CreateTypePanel()
    {
        GameObject typeLayoutObj = GameObject.Find("TypeLayout");
        int cellSize = 100;
        int typeNum = allEditorData.editorData.Count;
        RectTransform typeRect = typeLayoutObj.GetComponent<RectTransform>();
        typeRect.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Bottom, 0, cellSize * typeNum);
        GameObject baseItemMod = Resources.Load<GameObject>("DesignTools/BaseItem");

        foreach (MapEditorType editorTypeData in allEditorData.editorData)
        {
            GameObject newBaseItem = Instantiate(baseItemMod) as GameObject;
            newBaseItem.transform.SetParent(typeLayoutObj.transform);
            newBaseItem.GetComponent<Image>().overrideSprite = Resources.Load<Sprite>(editorTypeData.icon);

            Text itemLabel = newBaseItem.transform.GetChild(0).GetComponent<Text>();
            itemLabel.text = editorTypeData.name;

            Button itemButton = newBaseItem.GetComponent<Button>();
            MapEditorType newMapTypeData = editorTypeData;
            itemButton.onClick.AddListener(delegate () { OnClickTypeItem(newMapTypeData); });
        }
    }

    void TestOpenFile()
    {
#if UNITY_EDITOR
        string path = EditorUtility.OpenFilePanel("Load test csv file", "", "");
        WWW www = new WWW("file:///" + path);
        print(www.url);
        Debug.Log(www.text);
        CsvReader csvFile = new CsvReader();
        csvFile.SetData(www.text);
        Debug.Log(csvFile.GetDataByRowAndCol(2939, 0));
#endif
    }

    //载入地图编辑器数据
    private void LoadData()
    {
        UnityEngine.TextAsset s = null;
#if UNITY_EDITOR
         s = UnityEditor.AssetDatabase.LoadAssetAtPath<TextAsset>("Assets/PublishRes/DesignTools/MapEditorData" + ".jason");
        allEditorData = JsonMapper.ToObject<MapEditorData>(s.text);
#endif
    }

    //类别按钮响应
    void OnClickTypeItem(MapEditorType mapTypeData)
    {
        GameObject detailLayoutObj = GameObject.Find("DetailLayout");
        //删除旧的子节点
        while (detailLayoutObj.transform.childCount > 0)
        {
            DestroyImmediate(detailLayoutObj.transform.GetChild(0).gameObject);
        }

        //重新设置layout大小
        int cellSize = 100;
        int typeNum = mapTypeData.children.Count;
        RectTransform transRect = detailLayoutObj.GetComponent<RectTransform>();
        transRect.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Right, 0, cellSize * typeNum);

        GameObject baseItemMod = Resources.Load<GameObject>("DesignTools/BaseItem");
        foreach (MapEditorItem childItem in mapTypeData.children)
        {
            GameObject newBaseItem = Instantiate(baseItemMod) as GameObject;
            newBaseItem.transform.SetParent(detailLayoutObj.transform);
            newBaseItem.GetComponent<Image>().overrideSprite = Resources.Load<Sprite>(childItem.icon);

            Text ItemLabel = newBaseItem.transform.GetChild(0).GetComponent<Text>();
            ItemLabel.text = childItem.name;

            Button itemButton = newBaseItem.GetComponent<Button>();
            MapEditorItem newMapItemData = childItem;
            itemButton.onClick.AddListener(delegate () { OnClickDetailItem(newMapItemData); });
        }
    }


    //具体类型物体按钮响应
    void OnClickDetailItem(MapEditorItem mapItemData)
    {
        GameObject ownLayoutObj = GameObject.Find("OwnLayout");

        //重新设置layout大小
        int cellSize = 100;
        int itemNum = ownLayoutObj.transform.childCount + 1;
        RectTransform transRect = ownLayoutObj.GetComponent<RectTransform>();
        transRect.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Right, 0, cellSize * itemNum);

        //向own面板添加新的item
        GameObject newBaseItem = Instantiate(Resources.Load<GameObject>("DesignTools/BaseItem")) as GameObject;
        newBaseItem.transform.SetParent(ownLayoutObj.transform);
        newBaseItem.GetComponent<Image>().overrideSprite = Resources.Load<Sprite>(mapItemData.icon);
        
        Text itemLabel = newBaseItem.transform.GetChild(0).GetComponent<Text>();
        itemLabel.text = mapItemData.name;

        //载入模型
        GameObject resModel = Resources.Load<GameObject>(mapItemData.resPath);
        GameObject cloneModel = Instantiate(resModel) as GameObject;
        cloneModel.name = mapItemData.name;
        cloneModel.AddComponent<InstanceParam>();

        //item添加删除按钮
        GameObject closeBtn = Instantiate(Resources.Load<GameObject>("DesignTools/CloseBtn")) as GameObject;
        closeBtn.transform.SetParent(newBaseItem.transform);
        transRect = closeBtn.GetComponent<RectTransform>();
        Vector3 newPosition = transRect.localPosition;
        newPosition.y += 10;
        newPosition.x += 5;
        transRect.localPosition = newPosition;
        MapItemInstance ownItemInstance = new MapItemInstance();
        ownItemInstance.itemData = mapItemData;
        ownItemInstance.btnObj = newBaseItem;
        ownItemInstance.modelObj = cloneModel;
        ownInstanceList.Add(ownItemInstance);
        closeBtn.GetComponent<Button>().onClick.AddListener(delegate () { OnClickOwnItemClose(ownItemInstance); });
        newBaseItem.GetComponent<Button>().onClick.AddListener(delegate () { OnClickOwnItem(ownItemInstance); });
    }

    //已创建物体删除按钮
    void OnClickOwnItemClose(MapItemInstance itemInstance)
    {
        DestroyImmediate(itemInstance.btnObj);
        DestroyImmediate(itemInstance.modelObj);
    }

    //已创建物体按钮响应
    void OnClickOwnItem(MapItemInstance itemInstance)
    {
        //编辑面板中选中对象
        GameObject itemModel = itemInstance.modelObj;
#if UNITY_EDITOR
        EditorGUIUtility.PingObject(itemModel);
        Selection.activeGameObject = itemModel;
#endif

        //设置摄像头
        Vector3 pos = itemModel.transform.position;
        Vector3 newCamraPos = pos;
        newCamraPos.y += 5;
        newCamraPos.z -= 5;
        Camera.main.transform.position = newCamraPos;
        Camera.main.transform.LookAt(itemModel.transform);
    }
}
