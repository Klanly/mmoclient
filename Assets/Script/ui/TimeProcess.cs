using UnityEngine;
using UnityEngine.UI;

public class TimeProcess : MonoBehaviour
{
    public Image image;
    public float totoalTime = 20;
    public float calTime = 0;

    void Start()
    {
        image = transform.GetComponent<Image>();
        image.fillAmount = 0;
        calTime = 0;

        CancelInvoke("SetProcess");
        InvokeRepeating("SetProcess", 0, 0.1f);
    }

    void OnEnable()
    {
        Start();
    }

    public void SetProcess()
    {
        calTime += 0.1f;

        if (image)
        {
            image.fillAmount = calTime / totoalTime;
        }

        if (calTime >= totoalTime)
        {
            //失败
            //Util.CallMethod("StampUICtrl", "DestoyArrestPet");
            //Util.CallMethod("UIManager", "UnloadController", "StampUI");
            //Util.CallMethod("UIManager", "LoadController", "MainLandUI");
            //AppFacade.Instance.GetManager<ViewManager>(ManagerName.View).SetViewSiblingIndex("MainLandUI", 0);

            CancelInvoke("SetProcess");
        }
    }
}
