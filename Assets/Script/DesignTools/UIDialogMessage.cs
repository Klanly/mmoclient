using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;

public class UIDialogMessage : UIDialogBase
{

    private static UIDialogMessage instance;
    private Text Title;
    private Button ButtonExit;
    private Image Icon;
    private Text Message;
    private Button Button;

    void Awake()
    {
        instance = this;
        Message = transform.FindChild("Dialog/Text").GetComponent<Text>();
        Transform CloseBntTra = transform.FindChild("Dialog/Button");
        Button LoginBnt = CloseBntTra.GetComponent<Button>();
        LoginBnt.onClick.AddListener(delegate ()
        {
            Close(gameObject);
        });
        gameObject.SetActive(false);
        
    }

    public void SetUpData(string message)
    {
        Message.text = message;
    }

    private  void Close(GameObject go)
    {
        _Hide();
    }

    public static void Show(string message)
    {
        instance.SetUpData(message);
        instance.ShowProcess();
    }
}
