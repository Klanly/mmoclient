using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using System.Collections.Generic;

public class UIRoot : View
{
    private GameObject loading = null;
    private EventSystem kEventSystem = null;
    private CanvasRenderer[] kChildrenGo = null;
    private Transform kCamera = null;
    private View login = null;
    private GameObject inst = null;
    private GameObject kCanvas = null;
    GameObject kLoading = null;

    ///<summary>
    /// 监听的消息
    ///</summary>
    List<string> MessageList
    {
        get
        {
            return new List<string>()
            {
                NotiConst.LOADING_START,
                NotiConst.LOGIN_START,
                NotiConst.LOADING_End,
            };
        }
    }

    void Awake()
    {
        RegisterMessage(this, MessageList);
        DontDestroyOnLoad(this.gameObject);
        kEventSystem = GameObject.Find("EventSystem").GetComponent<EventSystem>();
        DontDestroyOnLoad(kEventSystem);
        kCanvas = transform.FindChild("Canvas").gameObject;
        kLoading = transform.FindChild("PopCanvas/loading").gameObject;
    }

    /// <summary>
    /// 处理View消息
    /// </summary>
    /// <param name="message"></param>
    public override void OnMessage(IMessage message)
    {
        string name = message.Name;
        object body = message.Body;
        switch (name)
        {
            case NotiConst.LOADING_START:      //初始化loading
                 StartLoading();
                break;
            case NotiConst.LOADING_End:      //初始化loading
                FinshLoading();
                break;
        }
    }


    void StartLoading()
    {
        if (loading != null) return;
        inst = Resources.Load("Loading/LoadingProgress") as GameObject;
        loading = GameObject.Instantiate(inst) as GameObject;
       // loading =  ObjectPoolManager.NewObject("Loading/LoadingProgress",EResType.eResUI,1.5f) as GameObject;
        if(loading)
        {
            Helper.AddChild(kLoading, loading);
            RectTransform rectTran = loading.GetComponent<RectTransform>();
            rectTran.localPosition = new Vector3(rectTran.localPosition.x, rectTran.localPosition.y, 0f);
            rectTran.offsetMax = Vector2.zero;
            rectTran.offsetMin = Vector2.zero;
            loading.SetActive(true);
        }
    }

    void FinshLoading()
    {
        Destroy(loading,0.3f);
        loading = null;
        inst = null;
    }

}
