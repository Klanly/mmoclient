using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Text;
using System.Collections.Generic;

public class LoadingProgressBar : View
{
    private Scrollbar kScrollbar = null;
	private Text kTiptxt = null;
    float kProgressvalue = 0;
    private string message = string.Empty;
    ///<summary>
    /// 监听的消息
    ///</summary>
    List<string> MessageList
    {
        get
        {
            return new List<string>()
            {
                NotiConst.UPDATE_MESSAGE,
                NotiConst.UPDATE_FINISHED,
                NotiConst.UPDATE_PROGRESS,
            };
        }
    }

    void Start()
    {
        kScrollbar = transform.FindChild("Scrollbar").GetComponent<Scrollbar>();
		kTiptxt = transform.FindChild("Tips").GetComponent<Text>();
        
        RegisterMessage(this, MessageList);
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
            case NotiConst.UPDATE_MESSAGE:      //更新消息
                UpdateMessage(body.ToString());
                break;
            case NotiConst.UPDATE_PROGRESS:      //更新消息
                UpdateProgress(float.Parse(body.ToString()));
                break;
            case NotiConst.UPDATE_FINISHED:     //更新完成
                UpdateFinished(body.ToString());
                break;
        }
    }

    void Update()
    {
        kScrollbar.size = kProgressvalue;
        kTiptxt.text = message;

    }

    public void UpdateMessage(string data)
    {
        message = data;
    }

    public void UpdateProgress(float ProgressPercentage)
    {
         kProgressvalue = ProgressPercentage;
    }

    public void UpdateFinished(string data)
    {
        message = data;
        AppFacade.Instance.SendMessageCommand(NotiConst.LOADING_End);


    }

    void OnDestroy()
    {
         kProgressvalue = 0;
         RemoveMessage(this, MessageList);
    }

}
