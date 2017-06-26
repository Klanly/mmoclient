using UnityEngine;
using System.Collections;
using UnityEditor;
using UnityEngine.UI;

public class UIEditor : Editor
{
	[MenuItem("GameObject/UI/Image")]
    static void CreatImage()
    {
        if (Selection.activeTransform)
        {
            if (Selection.activeTransform.GetComponentInParent<Canvas>())
            {
                GameObject go = new GameObject("image", typeof(Image));
                go.GetComponent<Image>().raycastTarget = false;
                go.transform.SetParent(Selection.activeTransform);
                Selection.activeTransform = go.transform;
            }
        }
    }
}
