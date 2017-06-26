using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class HoverEventListener : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    public delegate void BoolDelegate(PointerEventData e, bool isValue);

    public BoolDelegate onHover;

    public virtual void OnPointerEnter(PointerEventData eventData)
    {
        if (onHover != null)
            onHover(eventData, true);
    }

    public virtual void OnPointerExit(PointerEventData eventData)
    {
        if (onHover != null)
            onHover(eventData, false);
    }

    public static HoverEventListener Get(GameObject go)
    {
        HoverEventListener listener = go.GetComponent<HoverEventListener>();
        if (listener == null) listener = go.AddComponent<HoverEventListener>();
        var g = go.GetComponent<Graphic>();
        if (g != null)
        {
            g.raycastTarget = true;
        }
        return listener;
    }
}
