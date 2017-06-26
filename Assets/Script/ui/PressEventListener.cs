using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class PressEventListener : MonoBehaviour, IPointerDownHandler, IPointerUpHandler
{
    public delegate void BoolDelegate(PointerEventData e, bool isValue);

    public BoolDelegate onPress;

    public virtual void OnPointerDown(PointerEventData eventData)
    {
        if (onPress != null)
            onPress(eventData, true);
    }

    public virtual void OnPointerUp(PointerEventData eventData)
    {
        if (onPress != null)
            onPress(eventData, false);
    }

    public static PressEventListener Get(GameObject go)
    {
        PressEventListener listener = go.GetComponent<PressEventListener>();
        if (listener == null) listener = go.AddComponent<PressEventListener>();
        var g = go.GetComponent<Graphic>();
        if (g != null)
        {
            g.raycastTarget = true;
        }
        return listener;
    }
}
