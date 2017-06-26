/********************************************************************************
** auth： yanwei
** date： 2017-01-09
** desc： 循环切页功能的ScrollView。
*********************************************************************************/
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class ScrollViewLoop : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
{
	/// <summary>
	/// 坐标曲线
	/// </summary>
	public AnimationCurve PositionXCurve;
	public AnimationCurve PositionYCurve;
	public bool TurnPage = true;//切页功能
	private float Width = 0;
	private float height = 0;
	private RectTransform kRect;
	private Vector2 kstartpoint, kAddvect;
	private float kVec = 0;
	private bool kAnim = false;
	private float StartValue = 0.01f, AddValue = 0.25f, VMin = 0.01f, VMax = 1f;
	private List<ScrollViewLoopItem> Items = new List<ScrollViewLoopItem>();
    private List<ScrollViewLoopItem> kGotoFirstItems =new List<ScrollViewLoopItem>();
	private List<ScrollViewLoopItem> kGotoLastItems =new List<ScrollViewLoopItem>();
    private float kAddV = 0, kVk=0,kCurrentV=0,kVtotal=0,kVT=0;

    private float kAnimSpeed = 1f;

	private float ItemHeight = 100;
	private int LoopNumLast = 0;
	private int LoopNumFirst = 0;
	private bool bTurnPage = false;  //是否翻页成功
	private bool bDrag = false;
	private Action kFinishCallback = null;
	private Action kBeginCallback = null;

	int currentIndex = 0;
	int  TotalPage = 3;


	public void InitAllChild()
	{
		for (int i = transform.childCount - 1; i >= 0; i--)
		{
			Transform tran = transform.GetChild(i);
			tran.FindChild("imgSkill").gameObject.SetActive(false);
			tran.localPosition = Vector3.zero;
			ScrollViewLoopItem item = tran.GetComponent<ScrollViewLoopItem>();
			if(item)
			{
				item.Init(this);
				item.v = 0;
			}
		}
		Items.Clear();
		currentIndex = 0;
	}

	public Transform GetItemIndex(int index)
	{
		Items[index].Init(this);
		return Items[index].transform;
	}

	public void SetPage(int index) 
	{
		int conent = index - currentIndex;
		int AddContent = 0;
		if(conent == 0) return;
		if(conent > 0 )
		{
			AddContent = 4*conent; //向左
		}
		else
		{
			AddContent = - 4*conent; //向右
		}
        kAddV= AddValue*conent; 
		currentIndex = index;
		if(conent > 0)
			LeftShift( AddContent);
		else
			RightShift(AddContent);
		
		for (int i = 0; i < Items.Count; i++)
		{
			Items[i].v = 0;
			Items[i].Drag(StartValue + i * AddValue);
		}
	}

	public int GetCurrentIndex()
	{
		return currentIndex;
	}

	public void Init(Action onFinish = null,Action onBegin = null)
    {
		kRect = GetComponent<RectTransform>();
		Width = kRect.rect.width;
		height = kRect.rect.height;
		kFinishCallback = onFinish;
		kBeginCallback = onBegin;
		if (kRect.childCount < 5)
		{
			StartValue = StartValue + AddValue;
		}
		else
		{
			VMax = StartValue + (kRect.childCount - 1) * AddValue + AddValue*0.95f;
		}
		for (int i = 0; i < kRect.childCount; i++)
        {
			Transform tran = kRect.GetChild(i);
            ScrollViewLoopItem item = tran.GetComponent<ScrollViewLoopItem>();
			if(item == null)
				item = tran.gameObject.AddComponent<ScrollViewLoopItem>();
            if (item != null)
            {
                Items.Add(item);
                item.Init(this);
                item.Drag(StartValue + i * AddValue);
            }
        }

		if (kRect.childCount < 5)
		{
			enabled = false;
		}
		currentIndex = 1;
    }
	
	public void OnBeginDrag(PointerEventData eventData)
	{
		if(bDrag) return;
		kstartpoint = eventData.position;
		kAddvect = Vector3.zero;
		if(kBeginCallback !=null)
		   kBeginCallback();
	}

	public void OnDrag(PointerEventData eventData)
	{
		if(bDrag) return;
		kAddvect = eventData.position - kstartpoint;
		kVec = eventData.delta.x * 1.00f / Width;
		if(kAddvect.x < 0.1f && kAddvect.x > -0.1f) return;
		for (int i = 0; i < Items.Count; i++)
		{
			Items[i].Drag(kVec);
		}

		AuGenItem(kVec);
	}

	public void OnEndDrag(PointerEventData eventData)
	{
		if(bDrag) return;
		if(TurnPage)
		{
			if(kAddvect.x < 0.1f && kAddvect.x > -0.1f) return;
			int loopnum = LoopNumLast-LoopNumFirst;
			if(loopnum!= 0 ||kAddvect.x > ItemHeight||kAddvect.x < -ItemHeight)
			{
				kVtotal = 0;
				kAnim = true;
				kAnimSpeed = 3;
				bTurnPage = true;
				if (kAddvect.x > 0) 
				{ 
					loopnum = LoopNumFirst - LoopNumLast;
					kVk = 1; kAddV= AddValue*(4-loopnum) - Items[0].v; 
					if(currentIndex > 1)
					   currentIndex --;
					else
					   currentIndex = TotalPage;

				}
				else if (kAddvect.x < 0) 
				{ 
					kVk = -1; kAddV= -AddValue*(4-loopnum) -Items[0].v;
					if(currentIndex < TotalPage)
					   currentIndex ++;
					else
					   currentIndex = 1;
				}
			}
			else
			{
				float k  = 0;
				k  = -Items[0].v;
				kAddvect = Vector3.zero;
				AnimToEnd(k);
			}
		}
		else
		{
			float k = 0,v1;
			for (int i = 0; i < Items.Count; i++)
			{
				if (Items[i].v >= VMin)
				{
					v1 = (Items[i].v - VMin)%AddValue;
					if (kAddvect.x >= 0)
					{
						k = AddValue - v1;
					}
					else
					{
						k = v1 * -1;
					}
					break;
				}
			}
			kAddvect = Vector3.zero;
			AnimToEnd(k);
		}

	}
	
	void AnimToEnd(float k)
    {
        kAddV= k;
        if (kAddV > 0) { kVk = 1; }
        else if (kAddV < 0) { kVk = -1; }
        else
        {
            return;
        }
        kVtotal = 0;
		kAnim = true;

    }

	void Reverse( int p, int q)  
	{  
		for (; p<q; p++, q--)  
		{  
			ScrollViewLoopItem temp = Items[q];  
			Items[q] = Items[p];  
			Items[p] = temp;  
		}  
	}  

	void RightShift( int k)  
	{  
		int n = Items.Count;
		k %= n;  
		Reverse( 0, n - k - 1);  
		Reverse( n - k, n - 1);  
		Reverse( 0, n - 1);  
	} 

	void LeftShift( int k)  
	{  
		int n = Items.Count;
		k %= n;  
		Reverse( 0, k - 1);  
		Reverse( k, n - 1);  
		Reverse( 0, n - 1);  
	} 

    public Vector2 GetPosition(float v)
    {
		return new Vector2 (PositionXCurve.Evaluate(v) * Width - Width/2,PositionYCurve.Evaluate(v)* height - height/2 );
    }

	/// <summary>
	/// 自动生成下一个数据
	/// </summary>
	/// <param name="v">V.</param>
	void AuGenItem(float v)
    {
        if (v < 0)
        {//向左运动
            for (int i = 0; i < Items.Count; i++)
            {
                if (Items[i].v < (VMin - AddValue*0.75f))
                {
					kGotoLastItems.Add(Items[i]);
					LoopNumLast++;
               }
            }
			if (kGotoLastItems.Count > 0)
            {
				for (int i = 0; i < kGotoLastItems.Count; i++)
                {
					kGotoLastItems[i].v = Items[Items.Count - 1].v + AddValue;
					Items.Remove(kGotoLastItems[i]);
					Items.Add(kGotoLastItems[i]);
                }
				kGotoLastItems.Clear();
            }
        }
        else if (v > 0)
        {//向右运动，需要把右边的放到前面来

            for (int i = Items.Count-1; i >0; i--)
            {
                if (Items[i].v >= VMax)
                {
                    kGotoFirstItems.Add(Items[i]);
					LoopNumFirst++;
                }
            }
			if (kGotoFirstItems.Count > 0)
            {
				for (int i = 0; i < kGotoFirstItems.Count; i++)
                {
					kGotoFirstItems[i].v = Items[0].v - AddValue;
					Items.Remove(kGotoFirstItems[i]);
					Items.Insert(0, kGotoFirstItems[i]);
                }
				kGotoFirstItems.Clear();
            }
        }
    }
	
	 void Update()
    {
		if (kAnim)
        {
			bDrag = true;
			kCurrentV = Time.deltaTime * kAnimSpeed * kVk;
            kVT = kVtotal + kCurrentV;
			if (kVk > 0 && kVT >= kAddV) { kAnim = false; kCurrentV = kAddV - kVtotal; kAnimSpeed = 1; }
			if (kVk < 0 && kVT <= kAddV) { kAnim = false; kCurrentV = kAddV - kVtotal; kAnimSpeed = 1; }
            //==============
			for (int i = 0; i < Items.Count; i++)
			{
				Items[i].Drag(kCurrentV);
			}
			AuGenItem(kCurrentV);
            kVtotal = kVT;
			if(!kAnim)
			{
				LoopNumLast =0; 
				LoopNumFirst = 0;
				if(bTurnPage&&kFinishCallback !=null)
					kFinishCallback();
				bTurnPage = false;
				bDrag = false;
			}
        }
    }
}
