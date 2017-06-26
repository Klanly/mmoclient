using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
#if UNITY_IOS
using UnityEditor.iOS.Xcode;

using System.Collections;
using System.IO;
 
public class XcodeProjectMod : MonoBehaviour
{
    [PostProcessBuild]
    public static void OnPostprocessBuild(BuildTarget buildTarget, string path)
    {
        if (buildTarget == BuildTarget.iOS)
        {
            string projPath = PBXProject.GetPBXProjectPath(path);
            PBXProject proj = new PBXProject();
            proj.ReadFromString(File.ReadAllText(projPath));
            string target = proj.TargetGuidByName("Unity-iPhone");
            
            proj.SetBuildProperty(target, "ENABLE_BITCODE", "NO");
            proj.SetBuildProperty(target, "DEVELOPMENT_TEAM", "JLT4P23V2G"); 
            
            File.WriteAllText(projPath, proj.WriteToString());
            
            //Handle plist  
            string plistPath = path + "/Info.plist";  
            PlistDocument plist = new PlistDocument();  
            plist.ReadFromString(File.ReadAllText(plistPath));  
            PlistElementDict rootDict = plist.root;  
  
            //rootDict.SetString ("CFBundleVersion", GetVer ());//GetVer() 返回自定义自增值  
            rootDict.SetBoolean("UIFileSharingEnabled", true);
  
            File.WriteAllText(plistPath, plist.WriteToString());  
        }
    }
}
#endif