using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using LuaInterface;
using System.Reflection;
using System.IO;

public class EffectEditor: EditorWindow
{
    public class MotionEffectData
    {
        public GameObject effect = null;
        public GameObject rawEffect = null;
        public bool foldout = false;

        public float duration = 0;
        public float delayTime = 0;
        public string nodePath = "";
        public string effectPath = "";
        public Vector3 postion = Vector3.zero;
        public Vector3 rotation = Vector3.zero;
        public Vector3 scale = Vector3.one;
        public bool detach = false;
        public float delayDestroyTime = 0;

		public MotionEffectData() { }
		public MotionEffectData(LuaTable table)
        {
            nodePath = (string)table["nodePath"];
            effectPath = (string)table["effectPath"];
            delayTime = (float)((double)table["delayTime"]);
            duration = (float)((double)table["duration"]);
            detach = table["detach"]== null ? false : (bool)table["detach"];
            postion = new Vector3((float)((double)table["positionX"]), (float)((double)table["positionY"]), (float)((double)table["positionZ"]));
            rotation = new Vector3((float)((double)table["rotationX"]), (float)((double)table["rotationY"]), (float)((double)table["rotationZ"]));
            scale = new Vector3((float)((double)table["scaleX"]), (float)((double)table["scaleY"]), (float)((double)table["scaleZ"]));
            delayDestroyTime = table["delayDestroyTime"] == null ? 0 : (float)((double)table["delayDestroyTime"]);
        }
    }

    public class SkillEffectTableData
    {
        public GameObject effect = null;
        public GameObject rawEffect = null;
        public bool foldout = false;

        public float duration = 3;
        public float delayTime = 0;
        public string effectPath = "";
        public string node = ""; 

        public SkillEffectTableData() { }
        public SkillEffectTableData(LuaTable table)
        {
            effectPath = (string)table["effectPath"];
            delayTime = (float)((double)table["delayTime"]);
            node = (string)table["node"] == null?  "": (string)table["node"];
            duration = (float)((double)table["duration"]);
        }
    }

    public class OtherTableData
    {
        public float soundPlayTime = 0;
        public string soundRes = "";
        public float damagePlayTime = 1;

        public OtherTableData() { }
        public OtherTableData(LuaTable table)
        {
            soundRes = table["soundRes"] == null ? "" : (string)table["soundRes"];
            soundPlayTime = table["soundPlayTime"] == null ? 0 : (float)((double)table["soundPlayTime"]);
            damagePlayTime = table["damagePlayTime"] == null ? 0 : (float)((double)table["damagePlayTime"]);
        }
    }

    public class ShakeCamData
	{
		public float duration = 0;
		public float delayTime = 0;
		public bool IsStart = false;
		public float range = 0;
		public bool foldout = false;
		public ShakeCamData() { }

		public ShakeCamData(LuaTable table)
		{
			delayTime = (float)((double)table["delayTime"]);
			duration = (float)((double)table["duration"]);
			range = (float)((double)table["range"]);
		}
	}

    public class HitEffectData
    {
        public GameObject effect = null;
        public GameObject rawEffect = null;

        public string effectPath;
        public float startTime;
        public float duration;
        public string node = "";
        public Vector3 rotation;
        public bool detach;

        public HitEffectData() { }

        public HitEffectData(LuaTable table)
        {
            effectPath = (string)table["effectPath"];
            startTime = (float)((double)table["startTime"]);
            node = (string)table["node"];
            rotation = new Vector3((float)((double)table["rotationX"]), (float)((double)table["rotationY"]), (float)((double)table["rotationZ"]));
            duration = (float)((double)table["duration"]);
            detach = (bool)table["detach"];
        }
    }

    public class BulletEffectData
    {
        public GameObject effect = null;
        public GameObject rawEffect = null;

        public string effectPath;
        public float startTime;
        public float speed = 5;
        public Vector3 relativePos = Vector3.zero;
        public Vector3 scale = Vector3.one;
        public Vector3 curvePoint = Vector3.zero;
        public bool curve = false;
        public BulletEffectData() { }
        public BulletEffectData(LuaTable table)
        {
            effectPath = (string)table["effectPath"];
            startTime = (float)((double)table["startTime"]);
            relativePos = new Vector3((float)((double)table["relativePosX"]), (float)((double)table["relativePosY"]), (float)((double)table["relativePosZ"]));
            if (table["scaleX"] != null) scale = new Vector3((float)((double)table["scaleX"]), (float)((double)table["scaleY"]), (float)((double)table["scaleZ"]));
            if (table["speed"] != null) speed = (float)((double)table["speed"]);
            if (table["curvePointX"] != null) curvePoint = new Vector3((float)((double)table["curvePointX"]), (float)((double)table["curvePointY"]), (float)((double)table["curvePointZ"]));
            if (table["curve"] != null) curve = (bool)(table["curve"]);
        }
    }
    
    float clipTime = 0;
    float lastTime = 0;
    float loopTime = 6;
    bool loopPlay = false;
    int modelID = 1;
    int inputModelID = 1;
    string inputClipName = "";
    GameObject modelPath = null;
    GameObject model = null;
    GameObject beHitModel = null;
    GameObject damage = null;
    AudioSource audioSource = null;
    AnimationClip clip = null;
    Animation animation = null;
	List<MotionEffectData> motionEffectDatas = new List<MotionEffectData>();
    List<SkillEffectTableData> skillEffectDatas = new List<SkillEffectTableData>();
    List<ShakeCamData> ShakeCamtableDatas = new List<ShakeCamData>();
    List<BulletEffectData> BulletEffectDatas = new List<BulletEffectData>();
    List<HitEffectData> HitEffectDatas = new List<HitEffectData>();
    OtherTableData otherTableData = new OtherTableData();
    LuaManager luaMgr {
        get
        {
            if (lua != null) return lua;
            GameObject go = GameObject.Find("EffectEditorLuaManager");
            if (go != null) DestroyImmediate(go);
            GameObject root = new GameObject("EffectEditorLuaManager", typeof(LuaManager));
            lua = root.GetComponent<LuaManager>();
            lua.InitStart();
            lua.DoFile("Editor");
            return lua;
        }
    }
    LuaManager lua;
    bool play = false;

    void OnDestroy()
    {
        ClearScene();
    }
    
    void ClearScene()
    {
        try { if (lua != null) lua.Close(); lua = null; }
        finally
        {
            GameObject go = GameObject.Find("EffectEditorLuaManager");
            if (go != null) DestroyImmediate(go);
            if (model) DestroyImmediate(model);
            if (beHitModel) DestroyImmediate(beHitModel);
            if (damage) DestroyImmediate(damage);
            ClearEffectData();
            clip = null;
            damage = null;
            clipTime = 0;
            lastTime = 0;
            animation = null;
        }
    }


    void ResetEffectWroldPos(BulletEffectData data, float time)
    {
        var cachePoint = data.effect.transform.position;
        data.effect.transform.SetParent(model.transform);
        //data.effect.transform.localPosition = data.relativePos + time * Vector3.forward * data.speed;
        //data.effect.transform.SetParent(null);
        data.effect.transform.localPosition = data.relativePos;
        data.effect.transform.SetParent(null);
        Vector3 pre = data.effect.transform.position;
        Vector3 after = beHitModel.transform.Find("middle").position;
        data.effect.transform.SetParent(model.transform);
        data.effect.transform.localPosition = data.curvePoint;
        data.effect.transform.SetParent(null);
        Vector3 center = data.effect.transform.position;
        float t = time * data.speed / (after - pre).magnitude;
        Vector3 now = Vector3.zero;
        if (data.curve)
        {
            now = (1 - t) * (1 - t) * pre + 2 * (1 - t) * t * center + t * t * after;
        }
        else
        {
            now = (1 - t) * pre + t * after;
        }
        data.effect.transform.position = cachePoint;
        data.effect.transform.LookAt(now);
        data.effect.transform.position = now;
    }

    float lastSoundTime = 0;
    void PlaySoundAndDamage()
    {
        if (audioSource.clip && lastSoundTime < otherTableData.soundPlayTime  && otherTableData.soundPlayTime <= clipTime && ! audioSource.isPlaying)
        {
            audioSource.Play();
        }
        if ( lastSoundTime < otherTableData.damagePlayTime && otherTableData.damagePlayTime <= clipTime)
        {
            damage.SetActive(false);
            damage.SetActive(true);
        }
        lastSoundTime = clipTime;
    }

    void Update()
    {
        if (!Application.isPlaying)
        {
            ClearScene();
            return;
        }

        if (play)
        {
            clipTime += Time.realtimeSinceStartup - lastTime;
            lastTime = Time.realtimeSinceStartup;
        }

        if (clip == null) return;
        if (clipTime > loopTime)
        {
            clipTime = 0;
            lastSoundTime = -1;
            for (int i = 0; i < motionEffectDatas.Count; i++)
            {
                if (motionEffectDatas[i].effect != null)
                    motionEffectDatas[i].effect.SetActive(false);
            }
            for (int i = 0; i < BulletEffectDatas.Count; i++)
            {
                if (BulletEffectDatas[i].effect != null)
                    BulletEffectDatas[i].effect.SetActive(false);
            }
            for (int i = 0; i < HitEffectDatas.Count; i++)
            {
                if (HitEffectDatas[i].effect != null)
                    HitEffectDatas[i].effect.SetActive(false);
            }
            for (int i = 0; i < ShakeCamtableDatas.Count; i++)
			{
				ShakeCamtableDatas[i].IsStart  = false;
			}
        }
        for (int i = 0; i < motionEffectDatas.Count; i++)
        {
            PlayEffect(motionEffectDatas[i].effect,motionEffectDatas[i].delayTime);
        }
        for (int i = 0; i < skillEffectDatas.Count; i++)
        {
            PlayEffect(skillEffectDatas[i].effect, skillEffectDatas[i].delayTime);
        }
        for (int i = 0; i < BulletEffectDatas.Count; i++)
        {
            bool reset = false;
            if (BulletEffectDatas[i].effect != null)
            {
                reset = !BulletEffectDatas[i].effect.activeSelf;
                BulletEffectDatas[i].effect.transform.localScale = BulletEffectDatas[i].scale;
                if (moveBullet)
                    ResetEffectWroldPos(BulletEffectDatas[i],clipTime - BulletEffectDatas[i].startTime);
                PlayEffect(BulletEffectDatas[i].effect, BulletEffectDatas[i].startTime);
                if (!moveBullet)
                {
                    ResetEffectWroldPos(BulletEffectDatas[i],0);
                    BulletEffectDatas[i].effect.transform.rotation = model.transform.rotation;
                }
            }
        }
        for (int i = 0; i < HitEffectDatas.Count; i++)
        {
            PlayEffect(HitEffectDatas[i].effect, HitEffectDatas[i].startTime);
            if (!beHitModel.activeSelf)
            {
                HitEffectDatas[i].effect.SetActive(false);
            }
        }
        PlaySoundAndDamage();
        animation.clip.SampleAnimation(animation.gameObject, clipTime);
        Repaint();
		for (int i = 0; i < ShakeCamtableDatas.Count; i++)
		{
			if( clipTime>= ShakeCamtableDatas[i].delayTime&&!ShakeCamtableDatas[i].IsStart)
			{
				ShakeCamtableDatas[i].IsStart = true;
				CameraShake ctl = Camera.main.gameObject.GetComponent<CameraShake>();
				if (ctl == null)
				{
					ctl = Camera.main.gameObject.AddComponent<CameraShake>();
				}
				ctl.Shake(ShakeCamtableDatas[i].range,ShakeCamtableDatas[i].duration);
			}
				
		}
        beHitModel.SetActive(damageEffectFoldOut);
        beHitModel.transform.position = model.transform.position + model.transform.forward*8;
    }

    Vector2 scrollPos;
	bool EffectFoldOut = false;
    bool SkillEffectFoldOut = false;
    bool OtherDataFlodOut = false;
    bool moveBullet = false;
	Vector2 skscrollPos;
	bool ShakeCamFoldOut = false;
    bool damageEffectFoldOut = false;
    bool bulletEffectFoldOut = false;
    void OnGUI()
    {
        if (!Application.isPlaying) return;

        EditorGUILayout.BeginHorizontal();
        modelID = EditorGUILayout.IntField("配置ID", modelID);
        if (GUILayout.Button("加载配置", EditorStyles.miniButton, GUILayout.Width(65f)))
        {
            ClearScene();
            LoadModel();

        }
        if (GUILayout.Button("重置", EditorStyles.miniButton, GUILayout.Width(65f)))
        {
            ClearScene();
            return;
        }
        EditorGUILayout.EndHorizontal();
        //EditorGUILayout.LabelField("模型路径", modelPath);
        if (animation == null) return;
        int index = 0;
        foreach (var state in animation)
        {
            index++;
            if (index % 4 == 1)
            {
                EditorGUILayout.BeginHorizontal();
            }
            if (clip == animation.GetClip((state as AnimationState).name)) GUI.contentColor = Color.green;
            if (GUILayout.Button((state as AnimationState).name, EditorStyles.miniButton,GUILayout.MinWidth(50)))
            {
                clip = animation.GetClip((state as AnimationState).name);
                animation.clip = clip;
                animation.Play(clip.name);

				LoadDataFromLua();
                clipTime = 0;
            }
            GUI.contentColor = Color.white;
            if (index % 4 == 0)
            {
                EditorGUILayout.EndHorizontal();
            }
        }
        if (index % 4 != 0)
        {
            EditorGUILayout.EndHorizontal();
        }
        if (clip == null) return;
        EditorGUILayout.BeginHorizontal();
        loopPlay = EditorGUILayout.Toggle(loopPlay, GUILayout.Width(30f));
        if (loopPlay)
        {
            loopTime = clip.length;
        }
        loopTime = EditorGUILayout.FloatField(loopTime, GUILayout.Width(30f));
        
        clipTime = EditorGUILayout.Slider(clipTime, 0, loopTime);
        EditorGUILayout.EndHorizontal();
        if (!play)
        {
            if (GUILayout.Button("播放", EditorStyles.miniButton))
            {
                play = true;
                for (int i = 0; i < motionEffectDatas.Count; i++)
                {
                    if (motionEffectDatas[i].effect != null)
                        motionEffectDatas[i].effect.SetActive(false);
                }
            }
        }
        if (play && GUILayout.Button("暂停", EditorStyles.miniButton))
        {
            play = false;
        }
        EditorGUI.indentLevel = 0;
        GUILayout.Label("");
        EditorGUILayout.BeginHorizontal();
        EffectFoldOut = EditorGUILayout.Foldout(EffectFoldOut, "动作特效编辑");
        inputModelID = EditorGUILayout.IntField("     模型ID", inputModelID);
        inputClipName = EditorGUILayout.TextField("动作名", inputClipName);
        if (GUILayout.Button("copy", EditorStyles.miniButton))
        {
            LoadMotionEffectData(inputModelID, inputClipName);
        }
        EditorGUILayout.EndHorizontal();
        if (EffectFoldOut)
		{
			EditorGUI.indentLevel = 1;
			EditorGUILayout.BeginHorizontal();
			GUILayout.Label("",GUILayout.Width(40f));
			if (GUILayout.Button("添加特效", EditorStyles.miniButtonLeft, GUILayout.Width(150f)))
			{
				motionEffectDatas.Add(new MotionEffectData());
			}
			EditorGUILayout.EndHorizontal();
		
			scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
			for (int i = 0; i < motionEffectDatas.Count; i++)
			{
				EditorGUILayout.BeginHorizontal();
				motionEffectDatas[i].foldout = EditorGUILayout.Foldout(motionEffectDatas[i].foldout, i.ToString());
				if (GUILayout.Button("-", EditorStyles.miniButton, GUILayout.Width(55f)))
				{
					motionEffectDatas.RemoveAt(i);
					return;
				}
				EditorGUILayout.EndHorizontal();
				if(motionEffectDatas[i].foldout)
				{
					EditorGUILayout.BeginHorizontal();
					motionEffectDatas[i].rawEffect = (GameObject)EditorGUILayout.ObjectField("effectRes", motionEffectDatas[i].rawEffect, typeof(GameObject), false, GUILayout.Width(230));
					if (null != motionEffectDatas[i].rawEffect)
					{
						string path = AssetDatabase.GetAssetPath(motionEffectDatas[i].rawEffect.gameObject);
						path = path.Replace("Assets/Resources/Effect/", "").Replace(".prefab", "");
						motionEffectDatas[i].effectPath = path;
					}
					motionEffectDatas[i].effectPath = EditorGUILayout.TextField(motionEffectDatas[i].effectPath);
					EditorGUILayout.EndHorizontal();

					EditorGUILayout.BeginHorizontal();
					motionEffectDatas[i].nodePath = EditorGUILayout.TextField("nodePath", motionEffectDatas[i].nodePath);
					if (GUILayout.Button("load", EditorStyles.miniButton, GUILayout.Width(55f)))
					{
						//LoadEffect(i);
					}
					if (model != null && GUILayout.Button("path", EditorStyles.miniButton, GUILayout.Width(55f)))
					{
						SetNodePath(i);
					}
					EditorGUILayout.EndHorizontal();
					motionEffectDatas[i].postion = EditorGUILayout.Vector3Field("position", motionEffectDatas[i].postion);
					motionEffectDatas[i].rotation = EditorGUILayout.Vector3Field("rotation", motionEffectDatas[i].rotation);
					motionEffectDatas[i].scale = EditorGUILayout.Vector3Field("scale", motionEffectDatas[i].scale);
					motionEffectDatas[i].delayTime = EditorGUILayout.FloatField("delayTime", motionEffectDatas[i].delayTime);
                    motionEffectDatas[i].delayDestroyTime = EditorGUILayout.FloatField("delayDestroyTime", motionEffectDatas[i].delayDestroyTime);
                    motionEffectDatas[i].duration = EditorGUILayout.FloatField("duration", motionEffectDatas[i].duration);
					motionEffectDatas[i].detach = EditorGUILayout.Toggle("detach", motionEffectDatas[i].detach);
                }
				if (motionEffectDatas[i].effect != null)
				{
					motionEffectDatas[i].effect.transform.localPosition = motionEffectDatas[i].postion;
					motionEffectDatas[i].effect.transform.localEulerAngles = motionEffectDatas[i].rotation;
					motionEffectDatas[i].effect.transform.localScale = motionEffectDatas[i].scale;
				}
			}
			GUILayout.EndScrollView();
		}

        EditorGUI.indentLevel = 0;
        GUILayout.Label("");
        EditorGUILayout.BeginHorizontal();
        SkillEffectFoldOut = EditorGUILayout.Foldout(SkillEffectFoldOut, "技能特效编辑");
        inputModelID = EditorGUILayout.IntField("     模型ID", inputModelID);
        inputClipName = EditorGUILayout.TextField("动作名",inputClipName);
        if (GUILayout.Button("copy", EditorStyles.miniButton))
        {
            LoadSkillEffectData(inputModelID, inputClipName);
        }
        EditorGUILayout.EndHorizontal();
        if (SkillEffectFoldOut)
        {
            EditorGUI.indentLevel = 1;
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("", GUILayout.Width(40f));
            if (GUILayout.Button("添加特效", EditorStyles.miniButtonLeft, GUILayout.Width(150f)))
            {
                skillEffectDatas.Add(new SkillEffectTableData());
            }
            EditorGUILayout.EndHorizontal();

            scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
            for (int i = 0; i < skillEffectDatas.Count; i++)
            {
                EditorGUILayout.BeginHorizontal();
                skillEffectDatas[i].foldout = EditorGUILayout.Foldout(skillEffectDatas[i].foldout, i.ToString());
                if (GUILayout.Button("-", EditorStyles.miniButton, GUILayout.Width(55f)))
                {
                    skillEffectDatas.RemoveAt(i);
                    return;
                }
                EditorGUILayout.EndHorizontal();
                if (skillEffectDatas[i].foldout)
                {
                    EditorGUILayout.BeginHorizontal();
                    skillEffectDatas[i].rawEffect = (GameObject)EditorGUILayout.ObjectField("effectRes", skillEffectDatas[i].rawEffect, typeof(GameObject), false, GUILayout.Width(230));
                    if (null != skillEffectDatas[i].rawEffect)
                    {
                        string path = AssetDatabase.GetAssetPath(skillEffectDatas[i].rawEffect.gameObject);
                        path = path.Replace("Assets/Resources/Effect/", "").Replace(".prefab", "");
                        skillEffectDatas[i].effectPath = path;
                    }
                    skillEffectDatas[i].effectPath = EditorGUILayout.TextField(skillEffectDatas[i].effectPath);
                    EditorGUILayout.EndHorizontal();

                    skillEffectDatas[i].delayTime = EditorGUILayout.FloatField("delayTime", skillEffectDatas[i].delayTime);
                    skillEffectDatas[i].duration = EditorGUILayout.FloatField("duration", skillEffectDatas[i].duration);

                    EditorGUILayout.BeginHorizontal();
                    skillEffectDatas[i].node = EditorGUILayout.Toggle("middle", skillEffectDatas[i].node == "middle") ? "middle" : "";
                    skillEffectDatas[i].node = (EditorGUILayout.Toggle("bottom", skillEffectDatas[i].node == "")) ? "" : "middle";
                    EditorGUILayout.EndHorizontal();
                }
                if (skillEffectDatas[i].effect != null)
                {
                    var p = beHitModel.transform.Find(skillEffectDatas[i].node) ? beHitModel.transform.Find(skillEffectDatas[i].node).position : beHitModel.transform.position;
                    skillEffectDatas[i].effect.transform.localPosition = p;
                    skillEffectDatas[i].effect.transform.localEulerAngles = Vector3.zero;
                    skillEffectDatas[i].effect.transform.localScale = Vector3.one;
                }
            }
            GUILayout.EndScrollView();
        }
        EditorGUI.indentLevel = 0;
        GUILayout.Label("");
        EditorGUILayout.BeginHorizontal();
        OtherDataFlodOut = EditorGUILayout.Foldout(OtherDataFlodOut, "音效与冒字编辑");
        inputModelID = EditorGUILayout.IntField("     模型ID", inputModelID);
        inputClipName = EditorGUILayout.TextField("动作名", inputClipName);
        if (GUILayout.Button("copy", EditorStyles.miniButton))
        {
            LoadOtherData(inputModelID, inputClipName);
        }
        EditorGUILayout.EndHorizontal();
        if (OtherDataFlodOut)
        {
            EditorGUILayout.BeginHorizontal();
            audioSource.clip = (AudioClip)EditorGUILayout.ObjectField("soundClip", audioSource.clip, typeof(AudioClip), false, GUILayout.Width(230));
            if (null != audioSource.clip)
            {
                string path = AssetDatabase.GetAssetPath(audioSource.clip);
                path = path.Replace("Assets/Resources/Audio/", "").Replace(".wav", "");
                otherTableData.soundRes = path;
            }
            otherTableData.soundRes = EditorGUILayout.TextField(otherTableData.soundRes);
            otherTableData.soundPlayTime = EditorGUILayout.FloatField("soundPlayTime", otherTableData.soundPlayTime);
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.BeginHorizontal();
            otherTableData.damagePlayTime = EditorGUILayout.FloatField("damagePlayTime", otherTableData.damagePlayTime);
            EditorGUILayout.EndHorizontal();
        }
        EditorGUI.indentLevel = 0;
		GUILayout.Label("");
        EditorGUILayout.BeginHorizontal();
        ShakeCamFoldOut = EditorGUILayout.Foldout(ShakeCamFoldOut, "震屏编辑");
        inputModelID = EditorGUILayout.IntField("     模型ID", inputModelID);
        inputClipName = EditorGUILayout.TextField("动作名", inputClipName);
        if (GUILayout.Button("copy", EditorStyles.miniButton))
        {
            LoadShakeData(inputModelID, inputClipName);
        }
        EditorGUILayout.EndHorizontal();
        if (ShakeCamFoldOut)
		{
			EditorGUI.indentLevel = 1;
			EditorGUILayout.BeginHorizontal();
			GUILayout.Label("",GUILayout.Width(40f));
			if (GUILayout.Button("添加震屏效果", EditorStyles.miniButtonLeft, GUILayout.Width(150f)))
			{
				ShakeCamtableDatas.Add(new ShakeCamData());
			}
			EditorGUILayout.EndHorizontal();

			skscrollPos = EditorGUILayout.BeginScrollView(skscrollPos);

			for (int i = 0; i < ShakeCamtableDatas.Count; i++)
			{
				EditorGUILayout.BeginHorizontal();
				ShakeCamtableDatas[i].foldout = EditorGUILayout.Foldout(ShakeCamtableDatas[i].foldout, i.ToString());
				if (GUILayout.Button("-", EditorStyles.miniButton, GUILayout.Width(55f)))
				{
					ShakeCamtableDatas.RemoveAt(i);
					return;
				}
				EditorGUILayout.EndHorizontal();

				if(ShakeCamtableDatas[i].foldout)
				{
					ShakeCamtableDatas[i].delayTime = EditorGUILayout.FloatField("delayTime", ShakeCamtableDatas[i].delayTime);
					ShakeCamtableDatas[i].duration = EditorGUILayout.FloatField("duration", ShakeCamtableDatas[i].duration);
					ShakeCamtableDatas[i].range = EditorGUILayout.FloatField("range", ShakeCamtableDatas[i].range);
				}
			}

			GUILayout.EndScrollView();
		}
        EditorGUI.indentLevel = 0;
        GUILayout.Label("");
        EditorGUILayout.BeginHorizontal();
        damageEffectFoldOut = EditorGUILayout.Foldout(damageEffectFoldOut, "受击特效参数");
        inputModelID = EditorGUILayout.IntField("     模型ID", inputModelID);
        inputClipName = EditorGUILayout.TextField("动作名", inputClipName);
        if (GUILayout.Button("copy", EditorStyles.miniButton))
        {
            LoadHitEffectData(inputModelID, inputClipName);
        }
        EditorGUILayout.EndHorizontal();
        if (damageEffectFoldOut)
        {
            EditorGUI.indentLevel = 1;
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("", GUILayout.Width(40f));
            if (GUILayout.Button("添加受击特效", EditorStyles.miniButtonLeft, GUILayout.Width(150f)))
            {
                HitEffectDatas.Add(new HitEffectData());
            }
            EditorGUILayout.EndHorizontal();

            for (int i = 0; i < HitEffectDatas.Count; i++)
            {
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("-", EditorStyles.miniButton, GUILayout.Width(55f)))
                {
                    HitEffectDatas.RemoveAt(i);
                    return;
                }
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                HitEffectDatas[i].rawEffect = (GameObject)EditorGUILayout.ObjectField("effectRes", HitEffectDatas[i].rawEffect, typeof(GameObject), false, GUILayout.Width(230));
                if (null != HitEffectDatas[i].rawEffect)
                {
                    string path = AssetDatabase.GetAssetPath(HitEffectDatas[i].rawEffect.gameObject);
                    path = path.Replace("Assets/Resources/Effect/", "").Replace(".prefab", "");
                    HitEffectDatas[i].effectPath = path;
                }
                HitEffectDatas[i].effectPath = EditorGUILayout.TextField(HitEffectDatas[i].effectPath);
                EditorGUILayout.EndHorizontal();

                EditorGUILayout.BeginHorizontal();
                HitEffectDatas[i].startTime = EditorGUILayout.FloatField("startTime", HitEffectDatas[i].startTime);
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                HitEffectDatas[i].duration = EditorGUILayout.FloatField("duration", HitEffectDatas[i].duration);
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                HitEffectDatas[i].detach = EditorGUILayout.Toggle("detach", HitEffectDatas[i].detach);
                EditorGUILayout.EndHorizontal();

                EditorGUILayout.BeginHorizontal();
                HitEffectDatas[i].rotation = EditorGUILayout.Vector3Field("rotation", HitEffectDatas[i].rotation);
                EditorGUILayout.EndHorizontal();

                EditorGUILayout.BeginHorizontal();
                HitEffectDatas[i].node = EditorGUILayout.Toggle("middle", HitEffectDatas[i].node == "middle") ? "middle" : "";
                HitEffectDatas[i].node = (EditorGUILayout.Toggle("bottom", HitEffectDatas[i].node == "")) ? "" : "middle";
                EditorGUILayout.EndHorizontal();

                if (HitEffectDatas[i].effect != null)
                {
                    HitEffectDatas[i].effect.transform.position = beHitModel.transform.Find(HitEffectDatas[i].node)?beHitModel.transform.Find(HitEffectDatas[i].node).position: beHitModel.transform.position;
                    HitEffectDatas[i].effect.transform.eulerAngles = HitEffectDatas[i].rotation + model.transform.eulerAngles;
                    HitEffectDatas[i].effect.transform.localScale = Vector3.one;
                }
            }
        }
        EditorGUI.indentLevel = 0;
        GUILayout.Label("");
        EditorGUILayout.BeginHorizontal();
        bulletEffectFoldOut = EditorGUILayout.Foldout(bulletEffectFoldOut, "子弹特效参数");
        inputModelID = EditorGUILayout.IntField("     模型ID", inputModelID);
        inputClipName = EditorGUILayout.TextField("动作名", inputClipName);
        if (GUILayout.Button("copy", EditorStyles.miniButton))
        {
            LoadBulletEffectData(inputModelID, inputClipName);
        }
        EditorGUILayout.EndHorizontal();
        if (bulletEffectFoldOut)
        {
            EditorGUI.indentLevel = 1;
            GUILayout.Label("", GUILayout.Width(40f));

            EditorGUILayout.BeginHorizontal();
            moveBullet = EditorGUILayout.Toggle("移动子弹", moveBullet);
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("", GUILayout.Width(40f));
            if (GUILayout.Button("添加子弹特效", EditorStyles.miniButtonLeft, GUILayout.Width(150f)))
            {
                BulletEffectDatas.Add(new BulletEffectData());
            }
            EditorGUILayout.EndHorizontal();

            for (int i = 0; i < BulletEffectDatas.Count; i++)
            {
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("-", EditorStyles.miniButton, GUILayout.Width(55f)))
                {
                    BulletEffectDatas.RemoveAt(i);
                    return;
                }
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                BulletEffectDatas[i].rawEffect = (GameObject)EditorGUILayout.ObjectField("effectRes", BulletEffectDatas[i].rawEffect, typeof(GameObject), false, GUILayout.Width(230));
                if (null != BulletEffectDatas[i].rawEffect)
                {
                    string path = AssetDatabase.GetAssetPath(BulletEffectDatas[i].rawEffect.gameObject);
                    path = path.Replace("Assets/Resources/Effect/", "").Replace(".prefab", "");
                    BulletEffectDatas[i].effectPath = path;
                }
                BulletEffectDatas[i].effectPath = EditorGUILayout.TextField(BulletEffectDatas[i].effectPath);
                EditorGUILayout.EndHorizontal();

                EditorGUILayout.BeginHorizontal();
                BulletEffectDatas[i].startTime = EditorGUILayout.FloatField("startTime", BulletEffectDatas[i].startTime);
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                BulletEffectDatas[i].speed = EditorGUILayout.FloatField("speed", BulletEffectDatas[i].speed);
                EditorGUILayout.EndHorizontal();
                BulletEffectDatas[i].relativePos = EditorGUILayout.Vector3Field("relativePos", BulletEffectDatas[i].relativePos);
                BulletEffectDatas[i].scale = EditorGUILayout.Vector3Field("scale", BulletEffectDatas[i].scale);
                BulletEffectDatas[i].curve = EditorGUILayout.Toggle("curve", BulletEffectDatas[i].curve);
                if (BulletEffectDatas[i].curve)
                {
                    EditorGUILayout.BeginHorizontal();
                    BulletEffectDatas[i].curvePoint = EditorGUILayout.Vector3Field("curvePoint", BulletEffectDatas[i].curvePoint);
                    EditorGUILayout.EndHorizontal();
                }
            }
        }
        GUILayout.Label("");
		EditorGUILayout.BeginHorizontal();
		//if (GUILayout.Button("保存特效prefab", EditorStyles.miniButton))
		//{
		//	foreach (var data in tableDatas)
		//	{
		//		if (data.effectPath != "" && data.effect != null)
		//		{
		//			string prefabPath = string.Format("Assets/Resources/Effect/{0}.prefab", data.effectPath);
		//			Object prefab = PrefabUtility.CreateEmptyPrefab(prefabPath);
		//			PrefabUtility.ReplacePrefab(data.effect, prefab, ReplacePrefabOptions.ConnectToPrefab);
		//		}
		//	}
		//}
		if (GUILayout.Button("保存配置表", EditorStyles.miniButton))
		{
			WriteToCSV();
		}
		EditorGUILayout.EndHorizontal();
        
    }
    #region loadRes

    void ClearEffectData()
    {
        for (int i = 0; i < BulletEffectDatas.Count; i++)
        {
            DestroyImmediate(BulletEffectDatas[i].effect);
        }
        for (int i = 0; i < HitEffectDatas.Count; i++)
        {
            DestroyImmediate(HitEffectDatas[i].effect);
        }
        for (int i = 0; i < motionEffectDatas.Count; i++)
        {
            DestroyImmediate(motionEffectDatas[i].effect);
        }
        for (int i = 0; i < skillEffectDatas.Count; i++)
        {
            DestroyImmediate(skillEffectDatas[i].effect);
        }
        BulletEffectDatas = new List<BulletEffectData>();
        HitEffectDatas = new List<HitEffectData>();
        motionEffectDatas = new List<MotionEffectData>();
        ShakeCamtableDatas = new List<ShakeCamData>();
        skillEffectDatas = new List<SkillEffectTableData>();
    }

    void LoadMotionEffectData(int modelID,string clipName)
    {
        for (int i = 0; i < motionEffectDatas.Count; i++)
        {
            DestroyImmediate(motionEffectDatas[i].effect);
        }
        motionEffectDatas = new List<MotionEffectData>();
        LuaTable table = luaMgr.CallFunction("Editor.GetConfigTable", modelID, clipName, "motionEffects")[0] as LuaTable;
        if (table == null) return;
        var dicTable = table.ToDictTable();
        foreach (var x in dicTable)
        {
            motionEffectDatas.Add(new MotionEffectData(x.Value as LuaTable));
        }
        for (int i = 0; i < motionEffectDatas.Count; i++)
        {
            LoadEffect(i);
        }
    }
    void LoadSkillEffectData(int modelID, string clipName)
    {
        for (int i = 0; i < skillEffectDatas.Count; i++)
        {
            DestroyImmediate(skillEffectDatas[i].effect);
        }
        skillEffectDatas = new List<SkillEffectTableData>();
        LuaTable table = luaMgr.CallFunction("Editor.GetConfigTable", modelID, clipName, "skillEffects")[0] as LuaTable;
        if (table == null) return;
        var dicTable = table.ToDictTable();
        foreach (var x in dicTable)
        {
            skillEffectDatas.Add(new SkillEffectTableData(x.Value as LuaTable));
        }
        for (int i = 0; i < skillEffectDatas.Count; i++)
        {
            DestroyImmediate(skillEffectDatas[i].effect);
            skillEffectDatas[i].effect = LoadResToParent("Effect/" + skillEffectDatas[i].effectPath, null);
            skillEffectDatas[i].effect.transform.position = model.transform.position + model.transform.forward * 8;
            if (skillEffectDatas[i].effect == null) return;
            Bake(skillEffectDatas[i].effect);
        }
    }
    void LoadHitEffectData(int modelID, string clipName)
    {
        for (int i = 0; i < HitEffectDatas.Count; i++)
        {
            DestroyImmediate(HitEffectDatas[i].effect);
        }
        HitEffectDatas = new List<HitEffectData>();
        var table = luaMgr.CallFunction("Editor.GetConfigTable", modelID, clipName, "hitEffects")[0] as LuaTable;
        if (table == null) return;
        var dicTable = table.ToDictTable();
        foreach (var x in dicTable)
        {
            HitEffectDatas.Add(new HitEffectData(x.Value as LuaTable));
        }
        for (int i = 0; i < HitEffectDatas.Count; i++)
        {
            DestroyImmediate(HitEffectDatas[i].effect);
            HitEffectDatas[i].effect = LoadResToParent("Effect/" + HitEffectDatas[i].effectPath, null);
            if (HitEffectDatas[i].effect == null) break;
            Bake(HitEffectDatas[i].effect);
        }

    }

    void LoadBulletEffectData(int modelID, string clipName)
    {
        for (int i = 0; i < BulletEffectDatas.Count; i++)
        {
            DestroyImmediate(BulletEffectDatas[i].effect);
        }
        BulletEffectDatas = new List<BulletEffectData>();
        var table = luaMgr.CallFunction("Editor.GetConfigTable", modelID, clipName, "bulletEffects")[0] as LuaTable;
        if (table == null) return;
        var dicTable = table.ToDictTable();
        foreach (var x in dicTable)
        {
            BulletEffectDatas.Add(new BulletEffectData(x.Value as LuaTable));
        }
        for (int i = 0; i < BulletEffectDatas.Count; i++)
        {
            DestroyImmediate(BulletEffectDatas[i].effect);
            BulletEffectDatas[i].effect = LoadResToParent("Effect/" + BulletEffectDatas[i].effectPath, null);
            if (BulletEffectDatas[i].effect == null) break;
            Bake(BulletEffectDatas[i].effect);
        }

    }
    void LoadShakeData(int modelID, string clipName)
    {
        ShakeCamtableDatas = new List<ShakeCamData>();
        ///加载shake
        var table = luaMgr.CallFunction("Editor.GetConfigTable", modelID, clipName, "shakecam")[0] as LuaTable;
        if (table == null) return;
        var dicTable = table.ToDictTable();
        foreach (var x in dicTable)
        {
            ShakeCamtableDatas.Add(new ShakeCamData(x.Value as LuaTable));
        }
    }
    void LoadOtherData(int modelID, string clipName)
    {
        otherTableData = new OtherTableData(luaMgr.CallFunction("Editor.GetConfigTable", modelID, clipName, "otherData")[0] as LuaTable);
        audioSource.clip = Resources.Load("Audio/" + otherTableData.soundRes) as AudioClip;
    }

	void LoadDataFromLua()
	{
        LoadMotionEffectData(modelID, clip.name);
        LoadBulletEffectData(modelID, clip.name);
        LoadHitEffectData(modelID, clip.name);
        LoadSkillEffectData(modelID, clip.name);
        LoadShakeData(modelID, clip.name);
        LoadOtherData(modelID, clip.name);
    }
    void WriteToMotionEffectTable(string effectType)
    {
		luaMgr.CallFunction("Editor.StartWriteLuaTable", modelID, clip.name,effectType);
        for (int index = 0; index < motionEffectDatas.Count; index++)
        {
            int i = index + 1;
            var data = motionEffectDatas[index];
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "modelID", modelID);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "clipName", clip.name);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "effectIndex", i);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "effectPath", data.effectPath);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "nodePath", data.nodePath);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "delayTime", data.delayTime);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "duration", data.duration);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "detach", data.detach);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "positionX", data.postion.x);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "positionY", data.postion.y);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "positionZ", data.postion.z);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "rotationX", data.rotation.x);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "rotationY", data.rotation.y);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "rotationZ", data.rotation.z);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "scaleX", data.scale.x);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "scaleY", data.scale.y);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "scaleZ", data.scale.z);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "delayDestroyTime", data.delayDestroyTime);
        }
        lua.CallFunction("Editor.WriteLuaFile");
    }
    void WriteToSoundTable()
    {
        luaMgr.CallFunction("Editor.StartWriteLuaTable2", modelID, clip.name);
        if(otherTableData.soundRes != "")
        {
            lua.CallFunction("Editor.WriteLuaTable2", modelID, clip.name, "otherData", "modelID", modelID);
            lua.CallFunction("Editor.WriteLuaTable2", modelID, clip.name, "otherData", "clipName", clip.name);
            lua.CallFunction("Editor.WriteLuaTable2", modelID, clip.name, "otherData", "soundRes", otherTableData.soundRes);
            lua.CallFunction("Editor.WriteLuaTable2", modelID, clip.name, "otherData", "soundPlayTime", otherTableData.soundPlayTime);
        }
        lua.CallFunction("Editor.WriteLuaTable2", modelID, clip.name, "otherData", "damagePlayTime", otherTableData.damagePlayTime);
        lua.CallFunction("Editor.WriteLuaFile");
    }
    void WriteToHitEffectTable(string effectType)
    {
        luaMgr.CallFunction("Editor.StartWriteLuaTable", modelID, clip.name, effectType);
        for (int j = 0; j < HitEffectDatas.Count; j++)
        {
            int i = j + 1;
            var data = HitEffectDatas[j];
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "modelID", modelID);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "clipName", clip.name);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "effectIndex", i);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "effectPath", data.effectPath);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "startTime", data.startTime);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "rotationX", data.rotation.x);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "rotationY", data.rotation.y);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "rotationZ", data.rotation.z);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "node", data.node);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "detach", data.detach);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "duration", data.duration);
        }
        lua.CallFunction("Editor.WriteLuaFile");
    }
    void WriteToBulletEffectTable(string effectType)
    {
        luaMgr.CallFunction("Editor.StartWriteLuaTable", modelID, clip.name, effectType);
        for (int j = 0; j < BulletEffectDatas.Count; j++)
        {
            int i = j + 1;
            var data = BulletEffectDatas[j];
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "modelID", modelID);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "clipName", clip.name);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "effectIndex", i);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "effectPath", data.effectPath);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "startTime", data.startTime);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "relativePosX", data.relativePos.x);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "relativePosY", data.relativePos.y);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "relativePosZ", data.relativePos.z);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "scaleX", data.scale.x);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "scaleY", data.scale.y);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "scaleZ", data.scale.z);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "speed", data.speed);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "curve", data.curve);
            if(data.curve)
            {
                lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "curvePointX", data.curvePoint.x);
                lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "curvePointY", data.curvePoint.y);
                lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "curvePointZ", data.curvePoint.z);
            }
        }
        lua.CallFunction("Editor.WriteLuaFile");
    }

    void WriteToSkillEffectTable(string effectType)
    {
        luaMgr.CallFunction("Editor.StartWriteLuaTable", modelID, clip.name, effectType);
        for (int index = 0; index < skillEffectDatas.Count; index++)
        {
            int i = index + 1;
            var data = skillEffectDatas[index];
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "modelID", modelID);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "clipName", clip.name);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "effectIndex", i);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "effectPath", data.effectPath);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "delayTime", data.delayTime);
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "duration", data.duration);
        }
        lua.CallFunction("Editor.WriteLuaFile");
    }

    void WriteToShakeEffectTable(string effectType)
	{
		luaMgr.CallFunction("Editor.StartWriteLuaTable", modelID, clip.name,effectType);
		for (int j = 0; j < ShakeCamtableDatas.Count; j++)
		{
            int i = j + 1;
            var data = ShakeCamtableDatas[j];
            lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name,effectType, i, "delayTime", data.delayTime);
			lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "duration", data.duration);
			lua.CallFunction("Editor.WriteLuaTable", modelID, clip.name, effectType, i, "range", data.range);
		}
		lua.CallFunction("Editor.WriteLuaFile");
	}
    private string[] csvString;
    void WriteToCSV()
    {
		WriteToMotionEffectTable("motionEffects");
		WriteToShakeEffectTable("shakecam");
        WriteToHitEffectTable("hitEffects");
        WriteToBulletEffectTable("bulletEffects");
        WriteToSkillEffectTable("skillEffects");
        WriteToSoundTable();
        /*csvString = new string[tableDatas.Count + 2];

        csvString[0] = "模型ID,动作名,特效序号,特效路径,特效挂载点路径,是否脱离,延迟时间,持续时间,挂载偏移X,挂载偏移Y,挂载偏移Z,特效旋转X,特效旋转Y,特效旋转Z,特效缩放X,特效缩放Y,特效缩放Z";
        csvString[1] = "modleID,clipName,effectIndex,effectPath,nodePath,detach,delayTime,duration,positionX,positionY,positionZ,rotationX,rotationY,rotationZ,scaleX,scaleY,scaleZ";
        for (int i = 0; i < tableDatas.Count; i++)
        {
            csvString[i + 2] = modelID + "," + clip.name + "," + i + "," + tableDatas[i].effectPath + "," + tableDatas[i].nodePath + "," + (tableDatas[i].detach ? 0 : 1) + "," +
            string.Format("{0:0.00}", tableDatas[i].delayTime) + "," + string.Format("{0:0.00}", tableDatas[i].duration) + "," +
            string.Format("{0:0.00}", tableDatas[i].postion.x) + "," + string.Format("{0:0.00}", tableDatas[i].postion.y) + "," + string.Format("{0:0.00}", tableDatas[i].postion.z) + "," +
            string.Format("{0:0.00}", tableDatas[i].rotation.x) + "," + string.Format("{0:0.00}", tableDatas[i].rotation.y) + "," + string.Format("{0:0.00}", tableDatas[i].rotation.z) + "," +
            string.Format("{0:0.00}", tableDatas[i].scale.x) + "," + string.Format("{0:0.00}", tableDatas[i].scale.y) + "," + string.Format("{0:0.00}", tableDatas[i].scale.z);
        }

        string dir = "D:/" + modelID + "_" + clip.name + ".csv";
        string DirStr = Path.GetDirectoryName(dir);
        DirectoryInfo fileDirectoryInfo = new DirectoryInfo(DirStr);

        if (!fileDirectoryInfo.Exists)
            Directory.CreateDirectory(DirStr);

        if (File.Exists(dir))
            File.Delete(dir);

        if (!File.Exists(dir))
        {
            using (StreamWriter sw = new StreamWriter(dir, false, System.Text.Encoding.UTF8))
            {
                for (int i = 0; i < csvString.Length; i++)
                    sw.WriteLine(csvString[i]);
            }
        }*/

        EditorUtility.DisplayDialog("Tips", "导出完成", "ok");
    }


    void LoadModel()
    {
        if (model != null)
        {
            DestroyImmediate(model);
            model = null;
            clip = null;
            animation = null;
        }
        var o = luaMgr.CallFunction("Editor.GetModelPath", modelID);
        model = LoadResToParent("Character/" + o[0], null);
        model.transform.localEulerAngles = new Vector3(0,90,0);
        if (modelID < 10009 && modelID > 10000)
        {
            var o1 = luaMgr.CallFunction("Editor.GetClothes", modelID);
            ChangeClothes(model, o1);
        }
        beHitModel = GameObject.Instantiate(model);
        damage = GameObject.Instantiate(Resources.Load("UI/HpBarUI/damage") as GameObject);
        animation = model.GetComponentInChildren<Animation>();
        audioSource = model.AddComponent<AudioSource>();
        if (animation != null && animation.gameObject.GetComponent<Dress>() != null)
        {
            animation.gameObject.GetComponent<Dress>().Merge();
        }
		if(Camera.main.gameObject.GetComponent<CameraController>() == null)
			Camera.main.gameObject.AddComponent<CameraController>();
		Camera.main.gameObject.GetComponent<CameraController>().target_ = animation.gameObject.transform;
    }

    public static void ChangeClothes(GameObject root, params object[] dressInfos)
    {
        List<SkinMeshInfo> smiList = new List<SkinMeshInfo>();
        int num = 0;
        for (int i = 0; i < dressInfos.Length; i++)
        {
            if (dressInfos[i] == null || dressInfos[i] == "")
            {
                continue;
            }
            num++;
        }
        foreach (var dressInfo in dressInfos)
        {
            if (dressInfo == null || dressInfo == "")
            {
                continue;
            }
            var obj = GameObject.Instantiate(Resources.Load("Character/"+dressInfo) as GameObject);
            var part = obj as GameObject;
            if (part == null) return;
            DressPart p = part.GetComponent<DressPart>();
            if (p == null) return;
            smiList.Add(p.skinMeshInfo);
            ObjectPoolManager.RecycleObject(part);
            if (smiList.Count == num)
            {
                List<CombineInstance> combineInstances = new List<CombineInstance>();
                List<Material> materials = new List<Material>();
                List<Transform> bones = new List<Transform>();
                Transform[] transforms = root.GetComponentsInChildren<Transform>();

                foreach (var item in smiList)
                {
                    for (int sub = 0; sub < item.mesh.subMeshCount; sub++)
                    {
                        CombineInstance ci = new CombineInstance();
                        ci.mesh = item.mesh;
                        ci.subMeshIndex = sub;
                        combineInstances.Add(ci);
                    }

                    foreach (string bone in item.bonesName)
                    {
                        foreach (Transform transform in transforms)
                        {
                            if (transform.name != bone) continue;
                            bones.Add(transform);
                            break;
                        }
                    }
                    materials.AddRange(item.materials);
                }

                SkinnedMeshRenderer r = root.GetComponent<SkinnedMeshRenderer>();
                if (r == null) r = root.AddComponent<SkinnedMeshRenderer>();
                r.bones = bones.ToArray();
                r.materials = materials.ToArray();
                r.sharedMesh = new Mesh();
                r.sharedMesh.CombineMeshes(combineInstances.ToArray(), false, false);
                root.SetActive(false);
                root.SetActive(true);
            }

        }
    }

    void SetNodePath(int i)
    {
        if (motionEffectDatas[i].effect == null) return;

        string path = "";
        var tf = motionEffectDatas[i].effect.transform.parent;
        while (tf != model.transform)
        {
            if (tf == null)
            {
                motionEffectDatas[i].nodePath = "";
                return;
            }
            path = path == "" ? tf.name : tf.name + "/" + path;
            tf = tf.parent;
        }
        motionEffectDatas[i].nodePath = path;
    }

    void LoadEffect(int i)
    {
        DestroyImmediate(motionEffectDatas[i].effect);
        Transform node = model == null ? null : model.transform.Find(motionEffectDatas[i].nodePath);
        motionEffectDatas[i].effect = LoadResToParent("Effect/" + motionEffectDatas[i].effectPath, node);
        if (motionEffectDatas[i].effect == null) return;
        Bake(motionEffectDatas[i].effect);
    }

    GameObject LoadResToParent(System.Object obj, Transform parent)
    {
        GameObject gameObject = null;
        if (obj.GetType() == typeof(GameObject))
        {
            gameObject = obj as GameObject;
            if (gameObject == null) return null;
        }
        else if (obj.GetType() == typeof(string))
        {
            GameObject go = Resources.Load(obj as string) as GameObject;
            if (go == null) return null;
            gameObject = GameObject.Instantiate(go);
        }
        gameObject.SetActive(true);
        gameObject.transform.parent = parent;
        gameObject.transform.localPosition = Vector3.zero;
        gameObject.transform.localRotation = Quaternion.identity;
        gameObject.transform.localScale = Vector3.one;
        return gameObject;
    }
    #endregion

    #region EffectPlay
    void Bake(GameObject effect)
    {
        const float frameRate = 30f;
        const float kDuration = 5f;
        const int frameCount = (int)((kDuration * frameRate) + 2);

        var animators = effect.GetComponentsInChildren<Animator>();
        foreach (var animator in animators)
        {
            animator.Rebind();
            animator.StopPlayback();
            animator.recorderStartTime = 0;
            animator.StartRecording(frameCount);
            for (var i = 0; i < frameCount - 1; i++)
            {
                animator.Update(1.0f / frameRate);
            }
            animator.StopRecording();
            animator.StartPlayback();
        }
    }

    void PlayEffect(GameObject effect, float time)
    {
        if (effect != null)
            effect.SetActive(time <= clipTime);
        if (effect != null && effect.activeSelf)
        {
            EffectUpdate(effect, clipTime - time);
        }
    }

    void EffectUpdate(GameObject effect, float time)
    {
        var psArray = effect.GetComponentsInChildren<ParticleSystem>();
        foreach(var ps in psArray)
        {
            float cache = ps.startDelay;
            ps.startDelay = 0;
            ps.Simulate(time - cache, false);
            ps.startDelay = cache;
        }
        var animations = effect.GetComponentsInChildren<Animation>();
        foreach (var animation in animations)
        {
            animation.clip.SampleAnimation(animation.gameObject, time);
        }
        var animators = effect.GetComponentsInChildren<Animator>();
        foreach (var animator in animators)
        {
            animator.playbackTime = time;
            animator.Update(0);
        }
    }
    #endregion

    [MenuItem("DesignTools/动作特效编辑")]
    public static void DoWindow()
    {
        GetWindow<EffectEditor>("EffectWithAction");
    }
}

