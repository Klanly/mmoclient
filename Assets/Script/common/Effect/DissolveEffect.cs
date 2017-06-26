using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class DissolveEffect : Effect {

    public float FadeTimes = 1.9f;
    public string ShaderColorName = "_DissolveAmount";
    public string DissolveTex = "_DissolveSrc";
    private Renderer[] renders;
    private int matLength = 0;
    private List<Material> mats;
    private Color oldColor, currentColor;
    private float kDissolveAmount = 1;
    private int kDissolveTpye = 0;  //1 出生 2 死亡
    private float kOldAmount = 1;

    void MaterialsInit()
    {
        renders = transform.GetComponentsInChildren<Renderer>();
        if (renders != null)
        {
            matLength = renders.Length;
        }
        mats = new List<Material>();
        for (int i = 0; i < matLength; i++)
        {
            if (ExceptRenderer(renders[i])) continue;
            if (!renders[i].material.HasProperty(ShaderColorName) || !renders[i].material.HasProperty(DissolveTex)
                ||renders[i].material.GetTexture(DissolveTex) == null) continue;
            mats.Add(renders[i].material);
        }

    }

    private bool ExceptRenderer(Renderer renderer)
    {
        if (renderer is SpriteRenderer || renderer is ParticleSystemRenderer || renderer.gameObject.layer == LayerMask.NameToLayer("Default"))
            return true;
        else
            return false;
    }

    public override void SetEffect(params object[] args)
    {
        MaterialsInit();
        int count = args == null ? 0 : args.Length;
        kDissolveTpye = 1;
        kOldAmount = 1;
        if(count > 0)
        {
            string dissType = args[0].ToString();
            if (dissType.CompareTo("Death") == 0)
            {
                kOldAmount = 0;
                kDissolveTpye = 2;
            }
        }
    }

    public override void OnUpdate(float deltaTime)
    {
        if (kDissolveTpye == 1)
        {
            BornInDissolve(deltaTime);
        }
        else if (kDissolveTpye == 2)
        {
            DieInDissolve(deltaTime);
        }

    }

    private void DieInDissolve(float deltaTime)
    {
        kDissolveAmount = kOldAmount + deltaTime / FadeTimes;
        for (int i = 0; i < mats.Count; i++)
        {
            mats[i].SetFloat(ShaderColorName, kDissolveAmount);

        }
        kOldAmount = kDissolveAmount;
        if (kDissolveAmount >= 1)
        {
            RevertEffect();
            RevertComplited = true;
        }
            
    }

    private void BornInDissolve(float deltaTime)
    {
        kDissolveAmount = kOldAmount - deltaTime / FadeTimes;
        for (int i = 0; i < mats.Count; i++)
        {
            mats[i].SetFloat(ShaderColorName, kDissolveAmount);

        }
        kOldAmount = kDissolveAmount;
        if (kDissolveAmount <= 0)
            RevertComplited = true;
    }

    public override void RevertEffect()
    {
        for (int i = 0; i < mats.Count; i++)
        {
            mats[i].SetFloat(ShaderColorName, 0);
        }
        kDissolveTpye = 0;
    }

    public override void OnRecycle()
    {
        kDissolveTpye = 0;
    }

}
