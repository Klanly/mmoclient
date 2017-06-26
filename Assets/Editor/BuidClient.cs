using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class BuidClientWizard : EditorWindow
{
    public string publicer_;
    public string name_;
    public static string Publishtarget_;
    public string version_;
    public bool hotupdate_;
    public bool optEffect_;
    public bool optScene_;
    public bool bDebug_ = false;
    [MenuItem("BuildClient/BuildWinClient")]
    static void PublishWin()
    {

        Publishtarget_ = "Win";
#if UNITY_STANDALONE
        Init();
#endif
    }

    [MenuItem("BuildClient/BuildAndroidClient")]
    static void PublishAndroid()
    {
        Publishtarget_ = "Android";
 #if UNITY_ANDROID
        Init();
#endif
    }

    [MenuItem("BuildClient/BuildIOSClient")]
    static void PublishIOS()
    {
#if UNITY_IOS
        Publishtarget_ = "IOS";
        Init();
#endif
    }

    static void  Init()
    {
        BuidClientWizard window = (BuidClientWizard)EditorWindow.GetWindow(typeof(BuidClientWizard));
        window.version_ = DateTime.Now.ToString("yyyy.MM.dd") + ".00";
        window.name_ = "通灵宝印";
    }

    void OnGUI()
    {
        name_ = EditorGUILayout.TextField("Name", name_);
        publicer_ = EditorGUILayout.TextField("Publicer", publicer_);
        GUILayout.Label("请输入版本号，格式-年.月.日.次，如2014.11.15.01", EditorStyles.boldLabel);
        version_ = EditorGUILayout.TextField("版本号", version_);
        bDebug_ = EditorGUILayout.Toggle("调试模式", bDebug_);
        if (GUILayout.Button("Start..."))
        {
            BulidTarget(name_, publicer_, version_, Publishtarget_,bDebug_);
        }
    }
    //这里封装了一个简单的通用方法。
    public static void BulidTarget(string name, string publicer, string ver, string target,bool isDebug)
    {
        string app_name = name + ver + publicer;

        string target_dir = string.Empty;
        string target_name = app_name + ".exe";
        BuildTargetGroup targetGroup = BuildTargetGroup.Standalone;
        BuildTarget buildTarget = BuildTarget.StandaloneWindows;
        string applicationPath = Application.dataPath.Replace("/Assets", "");
        target_dir = applicationPath + "/TargetWin";
        if (target == "Android")
        {
			string x86Dir = Application.dataPath + "/Plugins/x86";
			string x64Dir = Application.dataPath + "/Plugins/x86_64";
			if (Directory.Exists(x86Dir))
			{
				Directory.Delete(x86Dir, true);
			}
			if (Directory.Exists(x64Dir))
			{
				Directory.Delete(x64Dir, true);
			}
			AssetDatabase.Refresh();
			Packager.BuildAndroidResource();
            target_dir = applicationPath + "/TargetAndroid";
            target_name = app_name + ".apk";
            targetGroup = BuildTargetGroup.Android;
            buildTarget = BuildTarget.Android;
        }
        else if (target == "IOS")
        {
            target_dir = applicationPath + "/TargetIOS";
            target_name = app_name;
            targetGroup = BuildTargetGroup.iOS;
            buildTarget = BuildTarget.iOS;
        }
		else
			Packager.BuildWindowsResource();
        //每次build删除之前的残留
        if (Directory.Exists(target_dir))
        {
            if (File.Exists(target_name))
            {
                File.Delete(target_name);
            }
        }
        else
        {
            Directory.CreateDirectory(target_dir);
        }
        // Player Setting
        //
        PlayerSettings.companyName = "HF";
        //
        PlayerSettings.productName = name;
        //
        PlayerSettings.GetIconSizesForTargetGroup(targetGroup);

        //
        //
        PlayerSettings.defaultInterfaceOrientation = UIOrientation.LandscapeLeft;
        PlayerSettings.allowedAutorotateToLandscapeLeft = true;
        PlayerSettings.allowedAutorotateToLandscapeRight = true;
        PlayerSettings.allowedAutorotateToPortrait = false;
        PlayerSettings.allowedAutorotateToPortraitUpsideDown = false;
        //
        PlayerSettings.statusBarHidden = true;

        //
        PlayerSettings.apiCompatibilityLevel = ApiCompatibilityLevel.NET_2_0_Subset;
        //
        PlayerSettings.bundleVersion = ver;
        //
        PlayerSettings.forceSingleInstance = true;
        // bug？
        //PlayerSettings.gpuSkinning = true;
        //
        PlayerSettings.renderingPath = RenderingPath.Forward;
        //
        PlayerSettings.strippingLevel = StrippingLevel.Disabled;
        //
        PlayerSettings.stripUnusedMeshComponents = true;
       
        string[] SCENES = FindEnabledEditorScenes();
        

        BuildOptions options = BuildOptions.None;
        if (isDebug)
        {
            EditorUserBuildSettings.development = true;
            EditorUserBuildSettings.connectProfiler = true;
            options |= BuildOptions.Development;
            options |= BuildOptions.ConnectWithProfiler;
        }
        else
        {
            EditorUserBuildSettings.development = false;
            EditorUserBuildSettings.connectProfiler = false;
        }
        //开始Build场景，等待吧～
        GenericBuild(SCENES, target_dir + "/" + target_name, buildTarget, options);
        // 反定义宏
        PlayerSettings.SetScriptingDefineSymbolsForGroup(targetGroup, "");
    }
    private static string[] FindEnabledEditorScenes()
    {
        List<string> EditorScenes = new List<string>();
        foreach (EditorBuildSettingsScene scene in EditorBuildSettings.scenes)
        {
            if (!scene.enabled) continue;
            EditorScenes.Add(scene.path);
        }
        return EditorScenes.ToArray();
    }

    static void GenericBuild(string[] scenes, string target_dir, BuildTarget build_target, BuildOptions build_options)
    {
        EditorUserBuildSettings.SwitchActiveBuildTarget(build_target);
        string res = BuildPipeline.BuildPlayer(scenes, target_dir, build_target, build_options);

        if (res.Length > 0)
        {
            throw new Exception("BuildPlayer failure: " + res);
        }
    }
}
