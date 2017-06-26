using UnityEngine;
using System.Collections;

public class DelayEx : MonoBehaviour
{
    public float delayTime = 1.0f;
    public GameObject hold = null;
    private UVAnimation m_UVAnimation = null;
    // Use this for initialization
    void OnEnable()
    {
        if (transform.childCount == 0)
            return;
        if (hold == null)
            hold = transform.GetChild(0).gameObject;
        hold.SetActive(false);
        if (IsInvoking())
            CancelInvoke();
        Invoke("DelayFunc", delayTime);
    }

    void OnDisable()
    {
        if(hold != null)
        hold.SetActive(false);
    }
    void DelayFunc()
    {
        if (hold != null)
        {
            hold.SetActive(true);

            m_UVAnimation = hold.GetComponent<UVAnimation>();
            if (m_UVAnimation != null)
                m_UVAnimation.enabled = true;
        }
    }
}