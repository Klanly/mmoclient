using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System.Collections.Generic;

public class AndroidLogin : MonoBehaviour, IPointerClickHandler
{

    public virtual void OnPointerClick(PointerEventData eventData)
    {
#if UNITY_ANDROID
        //obj.Call("LoginClick");
#endif
    }
#if UNITY_ANDROID
    AndroidJavaClass clas;
    AndroidJavaObject obj;
    void Start()
    {
        clas = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        obj = clas.GetStatic<AndroidJavaObject>("currentActivity");
    }
#endif
}
