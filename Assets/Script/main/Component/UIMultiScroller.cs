//-------------------------------
//该Demo由风冻冰痕所写
//http://icemark.cn/blog
//转载请说明出处
//-------------------------------
using UnityEngine;
using System.Collections.Generic;
using System;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class UIMultiScroller : MonoBehaviour, IBeginDragHandler, IEndDragHandler
{
    private enum Arrangement { Horizontal, Vertical, }
    //单行或单列的Item数量
    private int maxPerLine = 5;
    //默认加载的行数，Vertical时为itemprefab的行数, horizontal时为itemprefab的列数
    private int viewCount = 6;

    private int cellPadiding = 5;
    private int cellWidth = 500;
    private int cellHeight = 100;

    private GameObject itemPrefab;

    private int _index = -1;
    private List<UIMultiScrollIndex> _itemList = new List<UIMultiScrollIndex>();
    private int _dataCount = 0;

    ScrollRect _scroll;
    private ScrollRect scroll
    {
        get {
            if (_scroll == null)
            {
                _scroll = GetComponent<ScrollRect>();
                if (_scroll == null) { Debug.LogError("没有找到 ScrollRect"); return null; }
                scroll.onValueChanged.RemoveAllListeners();
                scroll.onValueChanged.AddListener(delegate (Vector2 vec)
                {
                    OnValueChange(vec);
                });
            }
            return _scroll;
        }
    }
    private RectTransform _content
    {
        get
        {
            return _scroll.content;
        }
    }

    private Arrangement _movement { get { return scroll.horizontal ? Arrangement.Horizontal : Arrangement.Vertical; } }

    private bool m_Dragging = false;
    private Queue<UIMultiScrollIndex> _unUsedQueue = new Queue<UIMultiScrollIndex>();  //将未显示出来的Item存入未使用队列里面，等待需要使用的时候直接取出
    public Action<GameObject, int> OnItemUpdate;
    public Action<int> onPageChange = null;
    public bool page = false;
    public int pageOffset = 0;
    public float scaleParam = 0;
    int cachePageIndex = -1;

    public void SetPageIndex(int index)
    {
        if (page)
        {
            var moveAnchorPosition = Vector2.zero;
            if (_movement == Arrangement.Horizontal)
            {
                moveAnchorPosition = new Vector2(pageOffset - index * (cellWidth + cellPadiding), _content.anchoredPosition.y);
            }
            else
            {
                moveAnchorPosition = new Vector2(_content.anchoredPosition.x, index * (cellHeight + cellPadiding) - pageOffset);
            }
            _content.anchoredPosition = moveAnchorPosition;
        }
        if (index != cachePageIndex)
        {
            cachePageIndex = index;
            if (onPageChange != null)
            {
                onPageChange(index);
            }
            RefreshView();
        }
    }


    void LateUpdate()
    {
        if(page && !m_Dragging)
        {
            float nearestDistance = float.MaxValue;
            Vector2 cacheVector = Vector2.zero;
            int nearIndex = 0;
            for(int i=0;i<_itemList.Count;i++)
            {
                float d = (_itemList[i].GetComponent<RectTransform>().anchoredPosition + _content.anchoredPosition + new Vector2(-pageOffset,pageOffset)).magnitude;
                if (d < nearestDistance)
                {
                    nearestDistance = d;
                    cacheVector = _itemList[i].GetComponent<RectTransform>().anchoredPosition;
                    nearIndex = _itemList[i].Index;
                }
            }
            SetPageIndex(nearIndex);
        }
        if (m_Dragging)
        {
            for (int i = 0; i < _itemList.Count; i++)
            {
                UpdateItemScale(_itemList[i].gameObject);
            }
        }
    }

    public virtual void OnBeginDrag(PointerEventData eventData)
    {
        m_Dragging = true;
    }

    public virtual void OnEndDrag(PointerEventData eventData)
    {
        m_Dragging = false;
    }

    public void Init(GameObject itemprefab, int itemwidth, int itemheight, int padding, int rowcount, int colcount)
    {
        itemPrefab = itemprefab;
        cellWidth = itemwidth;
        cellHeight = itemheight;
        cellPadiding = padding;
        viewCount = rowcount;
        maxPerLine = colcount;
        cachePageIndex = -1;
    }

    public void OnValueChange(Vector2 pos)
    {
        int index = GetPosIndex();
        if (index < 0) { index = 0; }
        if (_index != index && index > -1)
        {
            _index = index;
            for (int i = _itemList.Count; i > 0; i--)
            {
                UIMultiScrollIndex item = _itemList[i - 1];
                if (item.Index < index * maxPerLine || (item.Index >= (index + viewCount) * maxPerLine))
                {
                    _itemList.Remove(item);
                    _unUsedQueue.Enqueue(item);
                }
            }

            for (int i = _index * maxPerLine; i < (_index + viewCount) * maxPerLine; i++)
            {
                if (i < 0) continue;
                if (i > _dataCount - 1) continue;
                bool isOk = false;
                foreach (UIMultiScrollIndex item in _itemList)
                {
                    if (item.Index == i) isOk = true;
                }
                if (isOk) continue;
                CreateItem(i);
            }
        }
    }

    /// <summary>
    /// 提供给外部的方法，添加指定位置的Item
    /// </summary>
    public void AddItem(int index)
    {
        if (index > _dataCount)
        {
            Debug.LogError("添加错误:" + index);
            return;
        }
        AddItemIntoPanel(index);
        DataCount += 1;
    }

    /// <summary>
    /// 提供给外部的方法，删除指定位置的Item
    /// </summary>
    public void DelItem(int index)
    {
        if (index < 0 || index > _dataCount - 1)
        {
            Debug.LogError("删除错误:" + index);
            return;
        }
        DelItemFromPanel(index);
        DataCount -= 1;
    }

    private void AddItemIntoPanel(int index)
    {
        for (int i = 0; i < _itemList.Count; i++)
        {
            UIMultiScrollIndex item = _itemList[i];
            if (item.Index >= index) item.Index += 1;
        }
        CreateItem(index);
    }

    private void DelItemFromPanel(int index)
    {
        int maxIndex = -1;
        int minIndex = int.MaxValue;
        for (int i = _itemList.Count; i > 0; i--)
        {
            UIMultiScrollIndex item = _itemList[i - 1];
            if (item.Index == index)
            {
                GameObject.Destroy(item.gameObject);
                _itemList.Remove(item);
            }
            if (item.Index > maxIndex)
            {
                maxIndex = item.Index;
            }
            if (item.Index < minIndex)
            {
                minIndex = item.Index;
            }
            if (item.Index > index)
            {
                item.Index -= 1;
            }
        }
        if (maxIndex < DataCount - 1)
        {
            CreateItem(maxIndex);
        }
    }

    private void CreateItem(int index)
    {
        UIMultiScrollIndex itemBase;
        if (_unUsedQueue.Count > 0)
        {
            itemBase = _unUsedQueue.Dequeue();
        }
        else
        {
            GameObject go = Instantiate(itemPrefab);
            if (go != null)
            {
                Transform t = go.transform;
                t.SetParent(_content, false);
                go.layer = _content.gameObject.layer;
            }
            go.SetActive(true);
            itemBase = go.GetComponent<UIMultiScrollIndex>();
            if(itemBase == null)
            {
                itemBase = go.AddComponent<UIMultiScrollIndex>();
            }
        }

        itemBase.Scroller = this;
        itemBase.Index = index;
        if(OnItemUpdate != null)
        {
            OnItemUpdate(itemBase.gameObject, index);
            UpdateItemScale(itemBase.gameObject);
        }
        _itemList.Add(itemBase);
    }

    private int GetPosIndex()
    {
        float fPosIndex = 0;
        int nCeilPosIndex = 0;
        switch (_movement)
        {
            case Arrangement.Horizontal:
                fPosIndex = _content.anchoredPosition.x / -(cellWidth + cellPadiding);
                nCeilPosIndex = Mathf.CeilToInt(fPosIndex);
                if (Mathf.Abs(fPosIndex-nCeilPosIndex) < 0.1f)
                    return nCeilPosIndex;
                else
                    return Mathf.FloorToInt(fPosIndex);         
            case Arrangement.Vertical:
                fPosIndex = _content.anchoredPosition.y / (cellHeight + cellPadiding);
                nCeilPosIndex = Mathf.CeilToInt(fPosIndex);
                if (Mathf.Abs(fPosIndex - nCeilPosIndex) < 0.1f)
                    return nCeilPosIndex;
                else
                    return Mathf.FloorToInt(fPosIndex);
        }
        return 0;
    }

    public Vector3 GetPosition(int i)
    {
        switch (_movement)
        {
            case Arrangement.Horizontal:
                return new Vector3(cellWidth * (i / maxPerLine), -(cellHeight + cellPadiding) * (i % maxPerLine), 0f);
            case Arrangement.Vertical:
                return new Vector3(cellWidth * (i % maxPerLine), -(cellHeight + cellPadiding) * (i / maxPerLine), 0f);
        }
        return Vector3.zero;
    }

    void UpdateItemScale(GameObject obj)
    {
        if (page && scaleParam > 0)
        {
            var anchoredPosition = obj.GetComponent<RectTransform>().anchoredPosition + _content.anchoredPosition + new Vector2(-pageOffset, pageOffset);
            float distance = Mathf.Abs(_movement == Arrangement.Horizontal ? anchoredPosition.x : +anchoredPosition.y);
            float max = (_movement == Arrangement.Horizontal ? scroll.viewport.rect.width : scroll.viewport.rect.height) * scaleParam;
            float scale = 1f - distance / max;
            for (int i = 0; i < obj.transform.childCount; i++)
            {
                obj.transform.GetChild(i).localScale = new Vector3(scale, scale, 1f);
            }
            var cg = obj.GetComponent<CanvasGroup>();
            if (cg == null) { cg = obj.AddComponent<CanvasGroup>(); }
            cg.alpha = scale;
        }
    }

    public int DataCount
    {
        get { return _dataCount; }
        set
        {
            _dataCount = value;
            UpdateTotalWidth();
        }
    }

    public void UpdateData(int dataCount, Action<GameObject, int> onitemupdate)
    {
        OnItemUpdate = onitemupdate;

        DataCount = dataCount;
        RefreshView();
    }

    private void RefreshView()
    {
        int count = _itemList.Count;
        for (int i = count -1;i >= 0; --i)
        {
            if (_itemList[i].Index >= DataCount)
            {
                DelItemFromPanel(_itemList[i].Index);
            }
            else
            {
                //可能数量更改，需要重新计算位置
                _itemList[i].Index = _itemList[i].Index;
                OnItemUpdate(_itemList[i].gameObject, _itemList[i].Index);
                UpdateItemScale(_itemList[i].gameObject);
            }
        }
        _index = -1;
        OnValueChange(Vector2.zero);
    }

    private void UpdateTotalWidth()
    {
        int lineCount = Mathf.CeilToInt((float)_dataCount / maxPerLine);
        switch (_movement)
        {
            case Arrangement.Horizontal:
                _content.sizeDelta = new Vector2(cellWidth * lineCount + cellPadiding * (lineCount - 1), _content.sizeDelta.y);
                break;
            case Arrangement.Vertical:
                _content.sizeDelta = new Vector2(_content.sizeDelta.x, cellHeight * lineCount + cellPadiding * (lineCount - 1));
                break;
        }
    }

    void OnDestroy()
    {
    }
}
