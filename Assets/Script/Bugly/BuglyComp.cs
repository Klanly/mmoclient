using UnityEngine;
using System;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Threading;
using System.Reflection;

//using BuglyUnity;

public class BuglyComp : MonoBehaviour
{
    private const string BuglyAppIDForiOS = "e2e3e5380d";
    private const string BuglyAppIDForAndroid = "6fe1ed0e91";

    void InitBuglySDK()
    {
        Debug.Log("InitBuglySDK");
        // TODO NOT Required. Set the crash reporter type and log to report
        // BuglyAgent.ConfigCrashReporter (1, 2);
#if DEBUG
        // 开启SDK的日志打印, 发布版本请务必关闭
        BuglyAgent.ConfigDebugMode(true);
#endif
        // TODO NOT Required. Register log callback with 'BuglyAgent.LogCallbackDelegate' to replace the 'Application.RegisterLogCallback(Application.LogCallback)'
        // BuglyAgent.RegisterLogCallback (CallbackDelegate.Instance.OnApplicationLogCallbackHandler);

        // BuglyAgent.ConfigDefault ("Bugly", null, "ronnie", 0);

#if UNITY_IPHONE || UNITY_IOS
        BuglyAgent.InitWithAppId (BuglyAppIDForiOS);
#elif UNITY_ANDROID
        BuglyAgent.InitWithAppId (BuglyAppIDForAndroid);
#endif

        // TODO Required. If you do not need call 'InitWithAppId(string)' to initialize the sdk(may be you has initialized the sdk it associated Android or iOS project),
        // please call this method to enable c# exception handler only.
        BuglyAgent.EnableExceptionHandler();

        // TODO NOT Required. If you need to report extra data with exception, you can set the extra handler
        // BuglyAgent.SetLogCallbackExtrasHandler (MyLogCallbackExtrasHandler);

        BuglyAgent.PrintLog(LogSeverity.LogInfo, "Init the bugly sdk");
    }

    //    // Extra data handler to packet data and report them with exception.
    //    // Please do not do hard work in this handler 
    //    Dictionary<string, string> MyLogCallbackExtrasHandler ()
    //    {
    //        // TODO Test log, please do not copy it
    //        BuglyAgent.PrintLog (LogSeverity.Log, "extra handler");
    //
    //        // TODO Sample code, please do not copy it
    //        Dictionary<string, string> extras = new Dictionary<string, string> ();
    //        extras.Add ("ScreenSolution", string.Format ("{0}x{1}", Screen.width, Screen.height));
    //        extras.Add ("deviceModel", SystemInfo.deviceModel);
    //        extras.Add ("deviceName", SystemInfo.deviceName);
    //        extras.Add ("deviceType", SystemInfo.deviceType.ToString ());
    //
    //        extras.Add ("deviceUId", SystemInfo.deviceUniqueIdentifier);
    //        extras.Add ("gDId", string.Format ("{0}", SystemInfo.graphicsDeviceID));
    //        extras.Add ("gDName", SystemInfo.graphicsDeviceName);
    //        extras.Add ("gDVdr", SystemInfo.graphicsDeviceVendor);
    //        extras.Add ("gDVer", SystemInfo.graphicsDeviceVersion);
    //        extras.Add ("gDVdrID", string.Format ("{0}", SystemInfo.graphicsDeviceVendorID));
    //
    //        extras.Add ("graphicsMemorySize", string.Format ("{0}", SystemInfo.graphicsMemorySize));
    //        extras.Add ("systemMemorySize", string.Format ("{0}", SystemInfo.systemMemorySize));
    //        extras.Add ("UnityVersion", Application.unityVersion);
    // 
    //        BuglyAgent.PrintLog (LogSeverity.LogInfo, "Package extra data");
    //        return extras;
    //    }

    // Use this for initialization
    void Start()
    {
        BuglyAgent.PrintLog(LogSeverity.LogInfo, "Bugly Component Start()");
        InitBuglySDK();
        BuglyAgent.PrintLog(LogSeverity.LogWarning, "Init bugly sdk done");
    }
}
