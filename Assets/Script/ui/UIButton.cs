using UnityEngine;
using UnityEngine.EventSystems;
using System.Collections.Generic;

public class UIButton : MonoBehaviour, IPointerDownHandler, IPointerUpHandler
{
    public float duration = 0.1f;

    public GameObject colorTweenObj;
    public Color fromColor = Color.white;
    public Color toColor = Color.gray;

    public GameObject scaleTweenObj;
    public float toScale = 1.1f;

    public List<GameObject> showObjs = new List<GameObject>();
    public List<GameObject> hideObjs = new List<GameObject>();

    Vector3 preScale = Vector3.one;
    BETween _bt_color = null;
    BETween btColor { set { if (_bt_color) { Destroy(_bt_color); } _bt_color = value; } }

    BETween _bt_scale = null;
    BETween btScale { set { if (_bt_scale) { Destroy(_bt_scale); } _bt_scale = value; } }

    void Awake()
    {
        if (scaleTweenObj)
        {
            preScale = scaleTweenObj.transform.localScale;
        }
    }

    void OnDestroy()
    {
        btColor = null;
        btScale = null;
    }

    public virtual void OnPointerDown(PointerEventData eventData)
    {
        if (colorTweenObj)
        {
            btColor = BETween.color(colorTweenObj, duration, toColor);
        }
        for (int i = 0; i < showObjs.Count; i++)
        {
            showObjs[i].SetActive(true);
        }
        for (int i = 0; i < hideObjs.Count; i++)
        {
            hideObjs[i].SetActive(false);
        }
        if (scaleTweenObj)
        {
            btScale = BETween.scale(scaleTweenObj, duration, preScale, new Vector3(preScale.x * toScale, preScale.y * toScale, preScale.z));
        }
    }

    public virtual void OnPointerUp(PointerEventData eventData)
    {
        if (colorTweenObj)
        {
            btColor = BETween.color(colorTweenObj, duration, fromColor);
        }
        for (int i = 0; i < showObjs.Count; i++)
        {
            showObjs[i].SetActive(false);
        }
        for (int i = 0; i < hideObjs.Count; i++)
        {
            hideObjs[i].SetActive(true);
        }
        if (scaleTweenObj)
        {
            btScale = BETween.scale(scaleTweenObj, duration, new Vector3(preScale.x * toScale, preScale.y * toScale, preScale.z), preScale);
        }
    }
}
