using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.IO;

public class PanelUnitProperty : MonoBehaviour {

    public Transform kToggleRoot;
    public GameObject[] contents;
    private GameObject kResUnitPrefab;
    private Toggle[] toggleButtons;
    private MapResProperty currentProp = null;
    private int PostPropEid = -1;

    void Start()
    {
        gameObject.SetActive(false);
    }

    public void Init ()
    {
        currentProp = MapDesignTools.instance.SelectedGO.GetComponent<MapResProperty>();
        if (PostPropEid == currentProp.GetEid())
        {
          //  return;
        }
            
        kResUnitPrefab = transform.FindChild("ResSelectedUnit").gameObject;
        toggleButtons = kToggleRoot.GetComponentsInChildren<Toggle>();
        for (int i = 0; i < contents.Length; ++i)
        {
            for (int j = contents[i].transform.childCount - 1; j >= 0; j--)
            {
                Destroy(contents[i].transform.GetChild(j).gameObject);
            }
            contents[i].transform.parent.parent.gameObject.SetActive(false);
        }
        FillContents();
        kResUnitPrefab.SetActive(false);
        contents[0].transform.parent.parent.gameObject.SetActive(true);//场景
        toggleButtons[0].isOn = true;
        PostPropEid = currentProp.GetEid();
    }

    public void CategorySelected(int value)
    {
        for (int i = 0; i < toggleButtons.Length; ++i)
        {
            contents[i].transform.parent.parent.gameObject.SetActive(toggleButtons[i].isOn ? true : false);

        }
        if (toggleButtons[value].isOn) return;
        if (MapDesignTools.instance.ClickedTf == null) return;
        Transform tf = MapDesignTools.instance.ClickedTf.FindChild("SelectedUnit");
        if (tf != null)
            DestroyImmediate(tf.gameObject);
    }

    void FillContents()
    {
        int index = 0;
        SortedList<int, MapResProperty> Lists = MapDataProccess.instance.ResList;
        IList<int> ilistValues = MapDataProccess.instance.ResList.Keys;
        for (int i = ilistValues.Count -1; i>-1;--i)
        {
            MapResProperty resProp = Lists[ilistValues[i]];
            if (resProp.GetEid() == currentProp.GetEid()) continue; //排除自身
            index = GetIdFormType(resProp.GetResType());
            AddResToolItem(resProp, index);
        }
        string path = ResDefine.GetResPath(EResType.eResScene);
        List<string> kExtList = new List<string>();
        ResDefine.GetResTypeFileExtList(EResType.eResScene, ref kExtList);
        DirectoryInfo dir = new DirectoryInfo(path);
        string[] dirs = Directory.GetDirectories(path, "*", SearchOption.AllDirectories);
        index = 10101;
        for (int k = 0; k < dirs.Length; k++)
        {
            ArrayList ArraryFiles = ResDefine.GetResourceFiles(dirs[k].ToString(), kExtList);
            string[] files = new string[ArraryFiles.Count];
            ArraryFiles.CopyTo(files);
            for (int i = 0; i < files.Length; i++)
            {
                FileInfo fi = new FileInfo(files[i]);
                MapResProperty resProp = new MapResProperty();
                resProp.SetName(fi.Name.Replace(".unity", ""));
                resProp.SetEid(index++);
                AddResToolItem(resProp, 4);
            }
        }
       
    }

    MapResSelectedUnit AddResToolItem(MapResProperty resProp ,int idx)
    {
        GameObject go = (GameObject)Instantiate(kResUnitPrefab, Vector3.zero, Quaternion.identity);
        go.transform.SetParent(contents[idx].transform);
        go.transform.localScale = Vector3.one;
        go.SetActive(true);
        MapResSelectedUnit selUnit = go.GetComponent<MapResSelectedUnit>();
        selUnit.Init();
        int eid = resProp.GetEid();
        if (currentProp.GetContainerFromID(eid) !=null)
        {
            MapResProperty.unitStauts mUnit = currentProp.GetContainerFromID(eid);
            selUnit.SetUnitStauts(mUnit.sStatus);
        }
        
        selUnit.setNameAndID(resProp.GetName(), resProp.GetIDStr());
        selUnit.SetEid(eid);
        
 
        return selUnit;
    }
    private int GetIdFormType(int iType)
    {
        int index = 0;
        switch(iType)
        {
            case 7:
                index = 0;
                break;
            case 10:
                index = 1;
                break;
            case 2:
                index = 2;
                break;
            case 6:
                index = 3;
                break;

        }

        return index;
    }

    public void SaveSelectedUnit()
    {
        currentProp.ClearContainer();
        for (int i = 0; i < contents.Length; ++i)
        {
            for (int j = contents[i].transform.childCount - 1; j >= 0; j--)
            {
                MapResSelectedUnit unitRes = contents[i].transform.GetChild(j).gameObject.GetComponent<MapResSelectedUnit>();
                if(unitRes.GetUnitStauts() != MapResSelectedUnit.ResUnitStatus.IsNone)
                {
                    bool isOn = (unitRes.GetUnitStauts() == MapResSelectedUnit.ResUnitStatus.IsOn) ? true : false;
                    MapResProperty.unitStauts TempunitRes = new MapResProperty.unitStauts();
                    TempunitRes.sID = unitRes.GetEid();
                    TempunitRes.sStatus = unitRes.GetUnitStauts();
                    currentProp.AddIdContainerList(unitRes.GetEid(), TempunitRes);
                }
            }

        }
        MapDesignTools.instance.HideUnitProp();
    }
}
