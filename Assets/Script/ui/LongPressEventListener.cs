using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class LongPressEventListener : MonoBehaviour, IPointerDownHandler, IPointerUpHandler ,IPointerExitHandler
{
    public delegate void VoidDelegate();

    public VoidDelegate onLongPress;
	public float respondTime = 1.2f;
	
	bool press = false;
	float pressTime = 0;
    public virtual void OnPointerDown(PointerEventData eventData)
    {
        press = true;
        pressTime = 0;
    }

    public virtual void OnPointerUp(PointerEventData eventData)
    {
		press = false;
		pressTime = 0;
    }
	
	public virtual void OnPointerExit(PointerEventData eventData)
    {
		press = false;
		pressTime = 0;
    }

	void Update()
	{
		if(press)
		{
			pressTime += Time.deltaTime;
			if(pressTime > respondTime)
			{
                onLongPress();
                press = false;
                pressTime = 0;
			}
		}
	}

    public static LongPressEventListener Get(GameObject go)
    {
        LongPressEventListener listener = go.GetComponent<LongPressEventListener>();
        if (listener == null) listener = go.AddComponent<LongPressEventListener>();
        var g = go.GetComponent<Graphic>();
        if (g != null)
        {
            g.raycastTarget = true;
        }
        return listener;
    }
}
