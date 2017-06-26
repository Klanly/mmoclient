using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.IO;
using System.Collections.Generic;

public class MapResItem : MonoBehaviour
{

    public Image kIocn;
    private int kResType;
    public Text resName = null;
    private string Respath = string.Empty;
    private Transform ResRoot = null;
    private string kName = string.Empty;
    private int ResID = 0;
    private int eID = 1; //元素ID

    public void Init(MapEditorItem resData, int resType)
    {
        kResType = resType;

#if UNITY_EDITOR
        kIocn.sprite = UnityEditor.AssetDatabase.LoadAssetAtPath<Sprite>("Assets/PublishRes/" + resData.icon + ".png");
#endif
        resName.text = resData.name;
        Respath = resData.resPath;
        kName = resData.name;
        ResID = resData.ID;
        eID = MapDataProccess.instance.GetLastID();
    }

    public void Clicked()
    {

        Vector2 screenCenter = new Vector2(Screen.width / 2, Screen.height / 2);
        
        Vector3 pos = MapDataProccess.instance.GetTerrainPos(screenCenter,true);
       
        if (pos == Vector3.zero)
        {
            UIDialogMessage.Show("位置错误，请重新放置");
            return;
        }
        else
        {
            pos.y += 0.01f;
            MapDesignTools.instance.InstantUnit(Respath, pos, eID, kResType, kName, ResID, Quaternion.identity,true);
        }
       
    }
}
