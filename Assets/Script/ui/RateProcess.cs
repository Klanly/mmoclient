using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class RateProcess : MonoBehaviour
{
    public Image image;

    void Start()
    {
        image = transform.GetComponent<Image>();
        image.fillAmount = 0;
    }

    void OnEnable()
    {
        Start();
    }

    public void SetProcess(float rate)
    {
        if (image)
        {
            image.fillAmount = rate;
        }
    }

}
