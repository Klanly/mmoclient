using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using System.Collections.Generic;
using UnityEngine.Events;

public class MapResSelectedUnit : MonoBehaviour {

    public enum ResUnitStatus
    {
        IsEx,
        IsOn,
        IsNone
    }
    private ResUnitStatus kUnitStatus = ResUnitStatus.IsNone;
    private int eID = 0;
    public EventTrigger trigger = null;
    Transform isOn ,isEx,img;
    private Text nameTxt = null;
    private Text idTxt = null;
    private Image kImg = null;
    private Toggle t;

    public void Init ()
    {
        isOn = transform.FindChild("IsOn");
        isEx = transform.FindChild("IsEx");
        img = transform.FindChild("Image");
        kImg = transform.GetComponent<Image>();
        img.gameObject.SetActive(false);
        nameTxt = transform.FindChild("Name Text").GetComponent <Text>();
        idTxt = transform.FindChild("ID Text").GetComponent<Text>();
        trigger.triggers = new List<EventTrigger.Entry>();
        
         EventTrigger.Entry entry = new EventTrigger.Entry();
         entry.eventID = EventTriggerType.PointerClick;

         entry.callback = new EventTrigger.TriggerEvent();
         UnityAction<BaseEventData> callback = new UnityAction<BaseEventData>(OnUnitStauts);
         entry.callback.AddListener(callback);

         trigger.triggers.Add(entry);
         t = GetComponent<Toggle>();
         t.onValueChanged.AddListener(isSelected);

    }

    void ChangeUnitStauts()
    {
        if(kUnitStatus == ResUnitStatus.IsNone)
        {
            isOn.gameObject.SetActive(false);
            isEx.gameObject.SetActive(false);
        }
        else if (kUnitStatus == ResUnitStatus.IsOn)
        {
            isOn.gameObject.SetActive(true);
            isEx.gameObject.SetActive(false);
        }
        else
        {
            isOn.gameObject.SetActive(false);
            isEx.gameObject.SetActive(true);
        }

    }

    public void setNameAndID(string name,string eid)
    {
        nameTxt.text = name;
        idTxt.text = eid;
    }

    public void SetEid(int eid)
    {
        eID = eid;
    }

    public int GetEid()
    {
        return eID;
    }

    void OnUnitStauts(BaseEventData arg0)
    {
        if(kUnitStatus == ResUnitStatus.IsNone)
        {
            kUnitStatus = ResUnitStatus.IsOn;
        }
        else if(kUnitStatus == ResUnitStatus.IsOn)
        {
            kUnitStatus = ResUnitStatus.IsEx;
        }
        else
        {
            kUnitStatus = ResUnitStatus.IsNone;
        }
        ChangeUnitStauts();
    }

    void SetImg(Sprite sprite)
    {
        if(sprite)
        {
            img.gameObject.SetActive(true);
            kImg.sprite = sprite;
            
        }
        else
        {
            img.gameObject.SetActive(false);
        }
    }

    public void SetUnitStauts(ResUnitStatus status)
    {
        kUnitStatus = status;
        ChangeUnitStauts();
    }

    public ResUnitStatus GetUnitStauts()
    {
        return kUnitStatus;
    }

    public void isSelected(bool on)
    {
        MapResProperty clickedUnit = MapDataProccess.instance.ResList[eID];
        if (on)
        {
            if (MapDesignTools.instance.ClickedTf == clickedUnit.transform) return;   //避免重复点击
            MapDesignTools.instance.ClickedTf = clickedUnit.transform;
            GameObject goResSign = null;
            GameObject gosel = null;
#if UNITY_EDITOR
            goResSign = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>("Assets/PublishRes/DesignTools/SelectedUnit"+".prefab");
#endif
            gosel = (GameObject)Instantiate(goResSign, Vector3.zero, Quaternion.identity);

            gosel.name = "SelectedUnit";
            gosel.transform.SetParent(clickedUnit.transform);
            gosel.transform.localPosition = Vector3.zero;
            gosel.transform.localEulerAngles = Vector3.zero;
        }
        else
        {
            Transform tf = clickedUnit.transform.FindChild("SelectedUnit");
            if(tf!=null)
               DestroyImmediate(tf.gameObject);
        }
    }


}
