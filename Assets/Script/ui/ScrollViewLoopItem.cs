using UnityEngine;
using System.Collections;

public class ScrollViewLoopItem : MonoBehaviour {

	private ScrollViewLoop parent;
    [HideInInspector]
    public RectTransform rect;
	[HideInInspector]
    public float v=0;
    private Vector3 p;
    private Color color;
	private GameObject kBgcountdown = null;
	private GameObject kLinecountdown = null;

    public void Init(ScrollViewLoop _parent)
    {
        rect = GetComponent<RectTransform>();
        parent = _parent;
		if(kBgcountdown == null)
		    kBgcountdown = transform.FindChild("bgcountdown").gameObject;
		if(kLinecountdown == null)
			kLinecountdown = transform.FindChild("linecountdown").gameObject;
		kBgcountdown.SetActive(false);
		kLinecountdown.SetActive(false);
		kLinecountdown.transform.localPosition = Vector3.zero;
    }

    public void Drag(float value)
    {
        v += value;
        p=rect.localPosition;
		p.x=parent.GetPosition(v).x;
		p.y=parent.GetPosition(v).y;
        rect.localPosition = p;
    }

}
