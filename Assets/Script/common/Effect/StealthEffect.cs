/********************************************************************************
** auth： yanwei
** date： 2017-2-18
** desc： 隐身效果 。
*********************************************************************************/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class StealthEffect : Effect {

	public float FadeTimes = 0.65f;
	public string ShaderColorName = "_Color";
	private Renderer[] renders;
	private int matLength = 0;
	private List< Material> mats;
	private Color oldColor,currentColor;
	private float StealthAlpha = 0.2f;

	void MaterialsInit () 
	{
		renders = transform.GetComponentsInChildren<Renderer>();
		if(renders!=null) 
		{
			matLength = renders.Length;
		}
        mats = new List<Material>();
		for(int i = 0;i< matLength;i++)
		{
			if(ExceptRenderer(renders[i]))  continue;
            for (int j = 0; j < renders[i].materials.Length;j++ )
                mats.Add(renders[i].materials[j]);
		}
		if(!mats[0].HasProperty(ShaderColorName)) return;
		oldColor = mats[0].GetColor(ShaderColorName);
		currentColor = new Color(oldColor.r,oldColor.g,oldColor.b,StealthAlpha);

	}

	private bool ExceptRenderer(Renderer renderer)
	{
		if(renderer is SpriteRenderer||renderer is ParticleSystemRenderer)
			return true;
		else
			return false;
	}

    public override void SetEffect(params object[] args)
	{
		MaterialsInit () ;
		for(int i = 0;i<mats.Count;i++)
		{
			mats[i].SetColor(ShaderColorName, currentColor);

		}
	}

	public override void RevertEffect()
	{
        for (int i = 0; i < mats.Count; i++)
		{
			mats[i].SetColor(ShaderColorName, oldColor);

		}
	}

	public override void  OnRecycle()
	{
		RevertEffect();
	}
}
