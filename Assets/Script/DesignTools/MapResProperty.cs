using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;

public class MapResProperty : MonoBehaviour {

    public class unitStauts
    {
        public int sID;
        public MapResSelectedUnit.ResUnitStatus sStatus; 
    }

    private int kResType;
    private string kName = string.Empty;
    private int eID = 0;
    private int ResID = 0;
    private SortedList<int, unitStauts> kIDContainerList = new SortedList<int, unitStauts>();
    private string resPath = string.Empty;
    public void SetName(string name)
    {
        kName = name;
    }


    public string GetName()
    {
        return kName;
    }

    public void SetResID(int resID)
    {
        ResID = resID;
    }


    public int GetResID()
    {
        return ResID;
    }

    public void SetResPath(string path)
    {
        resPath = path;
    }

    public string GetResPath()
    {
        return resPath;
    }

    public int GetEid()
    {
        return eID;
    }

   public string GetIDStr()
    {
        
        string strID =  string.Format("{0:D4}", eID);
        return SceneManager.GetActiveScene().buildIndex.ToString()+ strID;
    }

    public void SetEid(int id)
    {
        eID = id;
    }

    public Vector3 GetPos()
    {
        return transform.position;
    }

    public Vector3 GetRot()
    {
        return transform.rotation.eulerAngles;
    }

    public SortedList<int, unitStauts> GetIDContainerList()
    {
        return kIDContainerList;
    }

    public int GetResType()
    {
        return kResType;
    }

    public void AddIdContainerList(int id, unitStauts mResUnit)
    {
        if (kIDContainerList.ContainsKey(id))
            kIDContainerList[id] = mResUnit;
        else
            kIDContainerList.Add(id, mResUnit);
    }

    public void ClearContainer()
    {
        kIDContainerList.Clear();
    }


    public void SetResType(int restype)
    {
        kResType = restype;
    }


    public unitStauts GetContainerFromID(int id)
    {
        unitStauts mResUnit = null;
        if(kIDContainerList.TryGetValue(id, out mResUnit))
        {
            return mResUnit;
        }

        return null;
    }


}

