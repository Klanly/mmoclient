using UnityEngine;
using UnityEngine.UI;

using System;
using System.Collections.Generic;

public class TabControl : MonoBehaviour
{
    //[SerializeField]
    private List<GameObject> panels = new List<GameObject>();
    private GameObject current;

    public Sprite activeSprite;
    public Sprite deactiveSprite;

    public Action<int, bool> OnPanelChanged;

    public void AddTabPanel(GameObject go)
    {
        var img = go.GetComponent<Image>();
        if (img == null)
        {
            Debug.LogError("panel must contain Image component");
            return;
        }
        ClickEventListener.Get(img.gameObject).onClick = (data) => {
            setActivePanel(data.pointerPress);
        };
        panels.Add(go);
        go.GetComponent<Image>().sprite = deactiveSprite;

        if (OnPanelChanged != null)
        {
            OnPanelChanged(panels.Count - 1, false);
        }
    }
    public void Clear()
    {
        panels.Clear();
        current = null;
    }
    public void RemovePanel(GameObject go)
    {
        panels.Remove(go);
    }
    public void SetActivePanel(int index)
    {
        if(panels.Count < index)
        {
            return;
        }
        GameObject go = panels[index];
        setActivePanel(go);
    }

    private void setActivePanel(GameObject go)
    {
        //if(go == current)
        //{
        //    return;
        //}
        int index = -1;
        if(current != null)
        {
            current.GetComponent<Image>().sprite = deactiveSprite;
            index = panels.IndexOf(current);
            if(OnPanelChanged != null)
            {
                OnPanelChanged(index, false);
            }
        }
        current = go;
        current.GetComponent<Image>().sprite = activeSprite;

        index = panels.IndexOf(current);
        if (OnPanelChanged != null)
        {
            OnPanelChanged(index, true);
        }
    }
}