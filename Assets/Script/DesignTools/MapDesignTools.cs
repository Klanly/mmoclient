/********************************************************************************
** auth： yanwei
** date： 2016.9.13
** desc： 实现地图编辑器的功能，包括拖放，选怪
*********************************************************************************/

using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;
using System.IO;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class MapDesignTools : MonoBehaviour
{

    public GameObject prefabResItem;
    public GameObject[] contents;
    public RectTransform rtDialog;
    public GameObject helpTextTf;

    private Transform kToggleRoot;
    private Toggle[] toggleButtons;
    public static MapDesignTools instance;
    private GameObject resRoot;

    private Transform UnitPropertyPanel = null;
    private GameObject kSelectedGO = null;
    private Transform kClickedTf = null;

    private string[] csvString;
    public GameObject ResRoot
    {
        get { return resRoot; }
        set { resRoot = value; }
    }

    public GameObject SelectedGO
    {
        get { return kSelectedGO; }
        set { kSelectedGO = value; }
    }

    public Transform ClickedTf
    {
        get { return kClickedTf; }
        set { kClickedTf = value; }
    }

    public string FilePath = string.Empty;

    void Awake()
    {
        instance = this;
        resRoot = GameObject.Find("ResRoot");
    }

    void Start()
    {
        UnitPropertyPanel = transform.FindChild("PanelUnitProperty");
        kToggleRoot = transform.FindChild("PanelResTools/Dialog/ToggleRoot");
        toggleButtons = kToggleRoot.GetComponentsInChildren<Toggle>();
        for(int i = 1;i<contents.Length;i++)
        {
            contents[i].SetActive(false);
        }
    }

    public void HideShowHelp()
    {
        helpTextTf.SetActive(!helpTextTf.activeSelf);
    }

    public void CategorySelected(int value)
    {
        for (int i = 0; i < toggleButtons.Length; ++i)
        {
            contents[i].SetActive(toggleButtons[i].isOn ? true : false);
        }
    }
    
    private void FillContents(int id, MapEditorType mapResType)
    {
        toggleButtons[id].transform.Find("Label").GetComponent<Text>().text = mapResType.name;
        List<MapEditorItem> list = mapResType.children;
        for (int i = 0; i < list.Count; ++i)
        {
            MapResItem script = AddResToolItem(prefabResItem, id, i);
            script.Init(list[i], mapResType.type);
        }

    }

    public MapResItem AddResToolItem(GameObject prefab, int id, int i)
    {
        GameObject go = (GameObject)Instantiate(prefab, Vector3.zero, Quaternion.identity);
        go.transform.SetParent(contents[id].transform);
        go.transform.localScale = Vector3.one;

        MapResItem script = go.GetComponent<MapResItem>();

        go.GetComponent<CanvasGroup>().alpha = 0;

        BETween bt1 = BETween.alpha(go, 0.1f, 0.0f, 1.0f);
        bt1.delay = 0.1f * (float)i + 0.2f;

        BETween bt2 = BETween.scale(go, 0.2f, Vector3.one, new Vector3(1.1f, 1.1f, 1.1f));
        bt2.delay = bt1.delay;
        bt2.loopStyle = BETweenLoop.pingpong;

        return script;
    }

    public void OnButtonResTool()
    {
        if (SelectedGO)
        {
            Transform tf = SelectedGO.transform.FindChild("SelectedReg");
            DestroyImmediate(tf.gameObject);
            SelectedGO = null;
        }
        rtDialog.transform.parent.localPosition = Vector3.zero;
        rtDialog.transform.parent.gameObject.SetActive(true);

        List<MapEditorType> ListMapData = MapDataProccess.instance.allEditorData.editorData;
        for (int i = 0; i < contents.Length; ++i)
        {
            for (int j = contents[i].transform.childCount - 1; j >= 0; j--)
            {
                Destroy(contents[i].transform.GetChild(j).gameObject);
            }
        }

        for(int k =0;k< ListMapData.Count;k++)
        {
            MapEditorType mapData = ListMapData[k];
            FillContents(k, mapData);
        }

        BETween.anchoredPosition(rtDialog.gameObject, 0.3f, new Vector3(0, -500), new Vector3(0, 0)).method = BETweenMethod.easeOut;
        rtDialog.anchoredPosition = new Vector3(0, -500);
        BETween.alpha(rtDialog.gameObject, 0.3f, 0, 1.0f).method = BETweenMethod.easeOut;
        BETween.alpha(rtDialog.transform.parent.gameObject, 0.3f, 0.0f, 0.3f).method = BETweenMethod.easeOut;
    }

    public void Hide()
    {
        BETween.anchoredPosition(rtDialog.gameObject, 0.3f, new Vector3(0, -500)).method = BETweenMethod.easeOut;
        BETween.alpha(rtDialog.transform.parent.gameObject, 0.3f, 0.3f, 0.0f).method = BETweenMethod.easeOut;
        BETween.enable(rtDialog.transform.parent.gameObject, 0.01f, false).delay = 0.05f;

    }

    void Show()
    {
        gameObject.transform.localPosition = Vector3.zero;
        gameObject.SetActive(true);
        gameObject.GetComponent<Image>().color = new Color32(0, 0, 0, 0);

        for (int i = 0; i < contents.Length; ++i)
        {
            for (int j = contents[i].transform.childCount - 1; j >= 0; j--)
            {
                Destroy(contents[i].transform.GetChild(j).gameObject);
            }
        }
    }

    public void ShowUnitProp()
    {
        UnitPropertyPanel.gameObject.SetActive(true);
        UnitPropertyPanel.gameObject.GetComponent<PanelUnitProperty>().Init();
    }

    public void HideUnitProp()
    {
        UnitPropertyPanel.gameObject.SetActive(false);
        if (kClickedTf == null) return;
        Transform tf = kClickedTf.FindChild("SelectedUnit");
        if (tf != null)
            DestroyImmediate(tf.gameObject);
    }

    void ExportToFile(string dir)
    {
#if UNITY_EDITOR
       
        string fullFilePath = dir;

        string DirStr = Path.GetDirectoryName(dir);
        DirectoryInfo fileDirectoryInfo = new DirectoryInfo(DirStr);

        if (!fileDirectoryInfo.Exists)
            Directory.CreateDirectory(DirStr);

        if (File.Exists(dir))
            File.Delete(dir);

        if (!File.Exists(dir))
        {
            using (StreamWriter sw = new StreamWriter(dir, false, System.Text.Encoding.UTF8))
            {
                for (int i = 0; i < csvString.Length; i++)
                    sw.WriteLine(csvString[i]);
            }
        }

        EditorUtility.DisplayDialog("Tips", "导出完成", "ok");
#endif
    }

    public void OnClickExport()
    {
        int totalCnt = MapDataProccess.instance.ResList.Count;
        IList<int> ilistValues = MapDataProccess.instance.ResList.Keys;
        csvString = new string[totalCnt + 2];

        csvString[0] = "场景元素ID,元素类型,中文名称-策划用,模型ID,缩放,坐标X,坐标Y,坐标Z,朝向X,朝向Y,朝向Z,触发器参数2,响应事件容器,模型路径(临时用)";
        csvString[1] = "eID,Type,Name,ModelID,Scale,PointX,PointY,PointZ,ForwardX,ForwardY,ForwardZ,TrggerPara2,EventResponse,ResPath";
        int i = 0;
        for (;i< totalCnt;i++)
        {
            int id = ilistValues[i];
            MapResProperty ResPropData = MapDataProccess.instance.ResList[id];
            Transform modelTansform = ResPropData.transform;
            IList<int> idlistValues = ResPropData.GetIDContainerList().Keys;
            string ContainerlistStr = string.Empty;// 响应事件容器
            string TrggerPara2 = string.Empty; //触发器参数2
            for (int k = 0;k<idlistValues.Count;k++)
            {
                if(idlistValues[k] < 10100)
                {
                    MapResProperty ConResPropData = MapDataProccess.instance.ResList[idlistValues[k]];
                    if ((ResPropData.GetIDContainerList()[idlistValues[k]]).sStatus == MapResSelectedUnit.ResUnitStatus.IsEx)
                        ContainerlistStr += "!";
                    ContainerlistStr += ConResPropData.GetIDStr();
                    if (k != idlistValues.Count - 1)
                        ContainerlistStr += "|";

                   
                }
                else  //场景ID
                {
                    if ((ResPropData.GetIDContainerList()[idlistValues[k]]).sStatus == MapResSelectedUnit.ResUnitStatus.IsEx)
                        ContainerlistStr += "!";
                    ContainerlistStr += "SID:" + idlistValues[k];
                    if (k != idlistValues.Count - 1)
                        ContainerlistStr += "|";
                }
                
            }
            float PosY = modelTansform.localPosition.y;
            if (ResPropData.GetResType() == 18 || ResPropData.GetResType() == 16)
            {
                TrggerPara2 = string.Format("{0:0.00}", modelTansform.localScale.x) + "|" + string.Format("{0:0.00}", modelTansform.localScale.y) + "|" + string.Format("{0:0.00}", modelTansform.localScale.z);

                if(ResPropData.GetResType() == 18)
                    PosY =  modelTansform.localPosition.y - 1;
            }

            csvString[i+2] =  ResPropData.GetIDStr() + "," + ResPropData.GetResType() + ","+ ResPropData.GetName() + "," + ResPropData.GetResID() + "," + modelTansform.localScale.x + "," +
                string.Format("{0:0.00}", modelTansform.localPosition.x) + "," + string.Format("{0:0.00}", PosY) + "," + string.Format("{0:0.00}", modelTansform.localPosition.z)+","+
                string.Format("{0:0.00}", modelTansform.localEulerAngles.x) + "," + string.Format("{0:0.00}", modelTansform.localEulerAngles.y) + "," + string.Format("{0:0.00}", modelTansform.localEulerAngles.z) + ","+
                TrggerPara2+ ","+ContainerlistStr + ","+ResPropData.GetResPath();
        }

        UIFileSetting.Show("导出");
        UIFileSetting.SetOpera(ExportToFile);

    }

    string GetLastStr(string str, int num)
    {
        int count = 0;
        if (str.Length > num)
        {
            count = str.Length - num;
            str = str.Substring(count, num);
        }
        return str;
    }


    public void OnClickOpenFile()
    {
        OpenFile();
        
    }
    void OpenFile()
    {
 #if UNITY_EDITOR
        string path = EditorUtility.OpenFilePanel("Load test csv file", "", "");
        if (string.IsNullOrEmpty(path))
            return;
        MapDesignTools.instance.FilePath = path;
        WWW www = new WWW("file:///" + path);
        print(www.url);
        Debug.Log(www.text);
        CsvReader csvFile = new CsvReader();
        csvFile.SetData(www.text);
        int row = csvFile.GetRow() - 1;
        for (int i = 2;i< row;i++)
        {
            string eID = csvFile.GetDataByRowAndCol(i, 0);
          
            string resType = csvFile.GetDataByRowAndCol(i, 1);
            string resName = csvFile.GetDataByRowAndCol(i, 2);
            string resID = csvFile.GetDataByRowAndCol(i, 3);
            string resScale = csvFile.GetDataByRowAndCol(i, 4);
            string posX = csvFile.GetDataByRowAndCol(i, 5);
            string posY = csvFile.GetDataByRowAndCol(i, 6);
            string posZ = csvFile.GetDataByRowAndCol(i, 7);

            string rotX = csvFile.GetDataByRowAndCol(i, 8);
            string rotY = csvFile.GetDataByRowAndCol(i, 9);
            string rotZ = csvFile.GetDataByRowAndCol(i, 10);

            string TrggerPara2 = csvFile.GetDataByRowAndCol(i, 11);
            string ContrainID = csvFile.GetDataByRowAndCol(i, 12);

            string respath = csvFile.GetDataByRowAndCol(i, 13);
            string[] TrggerPara2Salce = TrggerPara2.Split(new char[] { '|'});
            string[] EventResponse = ContrainID.Split(new char[] { '|' });
            float posy = float.Parse(posY);
            if (int.Parse(resType) == 18)
                posy += 1;
            Vector3 pos = new Vector3(float.Parse(posX), posy, float.Parse(posZ));
            Quaternion rotation = Quaternion.Euler(float.Parse(rotX), float.Parse(rotY), float.Parse(rotZ));

            string id = GetLastStr(eID, 4);
            MapResProperty mRes =  InstantUnit(respath,pos,int.Parse(id),int.Parse(resType), resName, int.Parse(resID),rotation);
            if(TrggerPara2Salce.Length == 3)
            {
                mRes.transform.localScale = new Vector3(float.Parse(TrggerPara2Salce[0]), float.Parse(TrggerPara2Salce[1]), float.Parse(TrggerPara2Salce[2]));
            }
            for(int k = 0;k< EventResponse.Length;k++)
            {
                string conId = EventResponse[k];
                if (string.IsNullOrEmpty(conId)) break;
                int sId = 0;
                MapResProperty.unitStauts status = new MapResProperty.unitStauts();
               
                if (conId.Contains("!"))
                {
                    conId = GetLastStr(conId, 4);
                    sId = int.Parse(conId);
                    status.sStatus = MapResSelectedUnit.ResUnitStatus.IsEx;
                }
                else
                {
                    conId = GetLastStr(conId, 4);
                    sId = int.Parse(conId);
                    status.sStatus = MapResSelectedUnit.ResUnitStatus.IsOn;
                    status.sID = sId;
                }
                mRes.AddIdContainerList(sId, status);
            }
        }

#endif
    }
    public MapResProperty InstantUnit(string Respath, Vector3 pos, int eID, int kResType, string kName, int resID, Quaternion rot ,  bool bSelected = false)
    {
        GameObject goRes = null;
        GameObject goResSign = null;
        if (kResType!= 16)
        {
            goRes = Resources.Load<GameObject>(Respath);
        }
        else
        {
#if UNITY_EDITOR
            goRes =  UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>("Assets/PublishRes/"+ Respath + ".prefab");
#endif
        }
#if UNITY_EDITOR
        goResSign = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>("Assets/PublishRes/DesignTools/SelectedReg"+ ".prefab");
#endif
        if (goRes == null || goResSign == null) return null;
        if (pos == Vector3.zero)
        {
            UIDialogMessage.Show("位置错误，请重新放置");
            return null;
        }

        GameObject go = (GameObject)Instantiate(goRes, pos, rot);
        MapResProperty mResPro = go.AddComponent<MapResProperty>();

        if (MapDesignTools.instance.ResRoot == null)
        {
            MapDesignTools.instance.ResRoot = new GameObject("ResRoot");
        }
        go.transform.SetParent(MapDesignTools.instance.ResRoot.transform);
        mResPro.SetResType(kResType);
        mResPro.SetEid(eID);
        mResPro.SetName(kName);
        mResPro.SetResPath(Respath);
        mResPro.SetResID(resID);
        go.name = Path.GetFileName(Respath) + eID.ToString();
        if (kResType == 18)
        {
            BoxCollider collider = go.AddComponent<BoxCollider>();
            collider.size = new Vector3(1, 3, 3);
            collider.center = new Vector3(0, 1.5f, 0);
        }
       
        if (bSelected)
        {
            GameObject gosel = (GameObject)Instantiate(goResSign, pos, Quaternion.identity);

            gosel.name = "SelectedReg";
            gosel.transform.SetParent(go.transform);
            gosel.transform.localPosition = Vector3.zero;
            MapDesignTools.instance.SelectedGO = go;
        }

        MapDesignTools.instance.Hide();
        MapDataProccess.instance.ResList.Add(eID, mResPro);
        return mResPro;
    }


}
