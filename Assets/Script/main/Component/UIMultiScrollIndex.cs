//-------------------------------
//该Demo由风冻冰痕所写
//http://icemark.cn/blog
//转载请说明出处
//-------------------------------
using UnityEngine;

public class UIMultiScrollIndex : MonoBehaviour
{
    private UIMultiScroller _scroller;
    private int _index;

    void Awake()
    {
    }

    void Start()
    {
    }
    
    public int Index
    {
        get { return _index; }
        set
        {
            _index = value;
            transform.localPosition = _scroller.GetPosition(_index);
        }
    }
    public UIMultiScroller Scroller
    {
        set { _scroller = value; }
    }
}
