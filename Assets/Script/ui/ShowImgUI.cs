using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class ShowImgUI : MonoBehaviour {

    static public ShowImgUI currentShowImgUI;
    GameObject successObject;
    GameObject failureObject;

    // Use this for initialization
    void Start () {

        currentShowImgUI = this;
        successObject = transform.FindChild("success").gameObject;
        successObject.SetActive(false);
        failureObject = transform.FindChild("failure").gameObject;
        failureObject.SetActive(false);

        DontDestroyOnLoad(transform.parent);
    }

    static public void ShowImage(bool flag)
    {
        if (currentShowImgUI == null)
            return;

        if (flag)    //成功
        {
            currentShowImgUI.successObject.SetActive(true);
            currentShowImgUI.failureObject.SetActive(false);
        }
        else
        {
            currentShowImgUI.successObject.SetActive(false);
            currentShowImgUI.failureObject.SetActive(true);
        }

        currentShowImgUI.CancelInvoke("HideImag");
        currentShowImgUI.Invoke("HideImage", 1f);
    }

    void HideImage()
    {
        successObject.SetActive(false);
        failureObject.SetActive(false);
    }
}
