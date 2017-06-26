using UnityEngine;
using UnityEngine.UI;

 public class ShowTextUI : MonoBehaviour
{
    static public ShowTextUI currentShowTextUI;
    Text text;

    void Start()
    {
        text = gameObject.GetComponent<Text>();
        currentShowTextUI = this;
        gameObject.SetActive(false);

        DontDestroyOnLoad(transform.parent);
    }

    static public void SetText( string content)
    {
        if (currentShowTextUI == null)
            return;

        currentShowTextUI.text.text = content;

        currentShowTextUI.CancelInvoke("HideText");
        currentShowTextUI.Invoke("HideText", 1f);
        currentShowTextUI.gameObject.SetActive(true);
    }

    void HideText()
    {
        if (text == null)
            return;

        text.text = "";
        gameObject.SetActive(false);
    }

}
