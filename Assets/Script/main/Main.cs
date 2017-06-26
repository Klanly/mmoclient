using System;
using System.IO;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Text;

/// <summary>
/// 游戏启动组件，负责游戏版本检测，资源解压，热更
/// </summary>
public class Main : MonoBehaviour
{
    protected static bool initialize = false;
    private List<string> downloadFiles = new List<string>();

    /// <summary>
    /// 初始化游戏管理器
    /// </summary>
    void Awake()
    {
#if UNITY_IPHONE || UNITY_IOS || UNITY_ANDROID
        BuglyComp buglyComp = gameObject.GetComponent<BuglyComp>();
        if(buglyComp == null)
        {
            buglyComp = gameObject.AddComponent<BuglyComp>();
        }
#endif
        AppFacade.Instance.StartUp();   //启动游戏，下一步检测热更 
    }

    void Start()
    {
        DontDestroyOnLoad(gameObject);  //防止销毁自己
        //#if !UNITY_EDITOR
        Application.logMessageReceived += LogHandler;
        //#endif
        LogCenter.Instance().OpenTrace(LogTraceType.File);

        CheckExtractResource(); //释放资源
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
        if (Application.isMobilePlatform)
          Application.targetFrameRate = AppConst.GameFrameRate;
        AppFacade.Instance.gameManager.CullGroup = Camera.main.GetComponent<CullingGroupLoadRes>();
    }

    /// <summary>
    /// 释放资源
    /// </summary>
    public void CheckExtractResource()
    {
        if (!AppConst.PublishMode)
        {
            OnResourceInited();
            return;
        }
        bool isExists = Directory.Exists(Util.DataPath) && File.Exists(Util.DataPath + AppConst.PatchList);
        if (isExists)
        {
            AppFacade.Instance.SendMessageCommand(NotiConst.LOADING_START);
            StartCoroutine(OnUpdateResource());
            return;   //文件已经解压过了，自己可添加检查文件列表逻辑
        }
        AppFacade.Instance.SendMessageCommand(NotiConst.LOADING_START);
        StartCoroutine(OnExtractResource());    //启动释放协成 

    }

    IEnumerator OnExtractResource()
    {
        string dataPath = Util.DataPath;  //数据目录
        string resPath = Util.AppContentPath(); //游戏包资源目录
        StringBuilder kTips = null;
        if (Directory.Exists(dataPath)) Directory.Delete(dataPath, true);
        Directory.CreateDirectory(dataPath);

        string infile = resPath + AppConst.PublishServerList;
        string outfile = dataPath + AppConst.PublishServerList;
        if (File.Exists(outfile)) File.Delete(outfile);

        string message = "正在解包文件:>" + AppConst.PublishServerList;
        Util.Log("Serverlist", infile);
        Util.Log("Serverlist", outfile);
        if (Application.platform == RuntimePlatform.Android)
        {
            WWW www = new WWW(infile);
            yield return www;

            if (www.isDone)
            {
                File.WriteAllBytes(outfile, www.bytes);
            }
            www.Dispose();
            www = null;
            yield return 0;
        }
        else File.Copy(infile, outfile, true);
        yield return new WaitForEndOfFrame();

        infile = resPath + AppConst.PatchList;
        outfile = dataPath + AppConst.PatchList;
        if (File.Exists(outfile)) File.Delete(outfile);
        message = "正在解包文件:>" + AppConst.PatchList;
        Util.Log("Game", infile);
        Util.Log("Game", outfile);
        if (Application.platform == RuntimePlatform.Android)
        {
            WWW www = new WWW(infile);
            yield return www;

            if (www.isDone)
            {
                File.WriteAllBytes(outfile, www.bytes);
            }
            www.Dispose();
            www = null;
            yield return 0;
        }
        else File.Copy(infile, outfile, true);
        yield return new WaitForEndOfFrame();
        //释放所有文件到数据目录
        FilesConfig filelist = JsonHelp.LoadFromJsonFile<FilesConfig>(outfile);
        List<ResInfo> mShardInfos = filelist.mShardInfos;
        int filesLen = mShardInfos.Count;
        int cur = 0;
        for (int i = 0; i < filesLen; i++)
        {
            string f = mShardInfos[i].ResName;
            infile = resPath + f;  //
            outfile = dataPath + f;
            cur++;
            float value = cur / (float)filesLen;
            message = "正在解包文件:>" + f;

            kTips = new StringBuilder();
            kTips.Append(message);
            kTips.Append(string.Format("{0:P}", value));
            AppFacade.Instance.SendMessageCommand(NotiConst.UPDATE_MESSAGE, kTips.ToString());
            AppFacade.Instance.SendMessageCommand(NotiConst.UPDATE_PROGRESS, value);
            string dir = Path.GetDirectoryName(outfile);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

            if (Application.platform == RuntimePlatform.Android)
            {
                WWW www = new WWW(infile);
                yield return www;

                if (www.isDone)
                {
                    File.WriteAllBytes(outfile, www.bytes);
                }
                www.Dispose();
                www = null;
                yield return 0;
            }
            else
            {
                if (File.Exists(outfile))
                {
                    File.Delete(outfile);
                }
                File.Copy(infile, outfile, true);
            }
            yield return new WaitForEndOfFrame();
        }
        message = "解包完成!!!";
        AppFacade.Instance.SendMessageCommand(NotiConst.UPDATE_MESSAGE, message);
        yield return new WaitForSeconds(0.1f);

        message = string.Empty;
        if (AppConst.UpdateMode)
        {
            StartCoroutine(OnUpdateResource());//释放完成，开始启动更新资源
        }
        else
        {
            OnResourceInited();
            Invoke("OnUpdateFinsh", 0.1f);
        }

    }

    void OnUpdateFinsh()
    {
        string message = "完成";
        AppFacade.Instance.SendMessageCommand(NotiConst.UPDATE_FINISHED, message);
    }

    /// <summary>
    /// 启动更新下载，启动线程下载更新
    /// </summary>
    IEnumerator OnUpdateResource()
    {
        string message = string.Empty;
        if (!AppConst.UpdateMode)
        {
            message = "完成";
            OnResourceInited();
            //yield return new WaitForSeconds(0.1f);
            Invoke("OnUpdateFinsh", 0.1f);
            yield break;
        }
        string LocalServerList = Util.GetLocalServerList();
        string random = DateTime.Now.ToString("yyyymmddhhmmss");
        string dataPath = Util.DataPath;  //数据目录
        WWW www = new WWW(AppConst.PublishServerListUrl + "?v=" + random);
        yield return www;
        if (www.error != null)
        {
            OnResourceInited();
            Invoke("OnUpdateFailed", 0.1f);
            Invoke("OnUpdateFinsh", 0.1f);
            www.Dispose();
            www = null;
            yield break;
        }
        if (www.isDone)
        {
            if (!Directory.Exists(dataPath))
            {
                Directory.CreateDirectory(dataPath);
            }
            if (File.Exists(LocalServerList))
            {
                File.Delete(LocalServerList);
            }
            FileStream fileStream = null;
            StreamWriter streamWriter = null;
            fileStream = new FileStream(LocalServerList, FileMode.Create);
            string data = www.text;
            streamWriter = new StreamWriter(fileStream);
            streamWriter.Write(data);
            streamWriter.Flush();
            streamWriter.Close();
            fileStream.Close();

        }
        yield return 0;
        yield return new WaitForEndOfFrame();

        string url = AppConst.PatchListUrl;

        string listUrl = url + Util.GetPlatformWebUrl() + AppConst.PatchList + "?v=" + random;
        Util.Log("Game", "LoadUpdate---->>>" + listUrl);
        yield return new WaitForSeconds(0.1f);
        message = "正在验证资源....";
        AppFacade.Instance.SendMessageCommand(NotiConst.UPDATE_MESSAGE, message);
        www = new WWW(listUrl); yield return www;
        if (www.error != null)
        {
            OnResourceInited();
            Invoke("OnUpdateFailed", 0.1f);
            Invoke("OnUpdateFinsh", 0.1f);
            www.Dispose();
            www = null;
            yield break;
        }
        if (!Directory.Exists(dataPath))
        {
            Directory.CreateDirectory(dataPath);
        }
        File.WriteAllBytes(dataPath + AppConst.PatchList, www.bytes);
        string filesText = www.text;
        FilesConfig filelist = JsonHelp.ReadFromJsonString<FilesConfig>(filesText);
        List<ResInfo> mShardInfos = filelist.mShardInfos;
        string versionFloder = filelist.VerRevision.GetTxt();
        AppConst.Version = versionFloder;
        versionFloder = versionFloder.Replace('.', '_');
        string resUrl = filelist.PatchUrl + Util.GetPlatformWebUrl() + versionFloder + "/";
        if (filelist.AutoUpdate == false)
        {
            OnResourceInited();
            Invoke("OnUpdateFailed", 0.1f);
            Invoke("OnUpdateFinsh", 0.1f);
            www.Dispose();
            www = null;
            yield break;
        }
        for (int i = 0; i < mShardInfos.Count; i++)
        {
            string f = mShardInfos[i].ResName;
            string localfile = (dataPath + f).Trim();
            string path = Path.GetDirectoryName(localfile);
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            string fileUrl = resUrl + f + "?v=" + random;
            bool canUpdate = !File.Exists(localfile);
            if (!canUpdate)
            {
                string remoteMd5 = mShardInfos[i].md5;
                string localMd5 = Util.md5file(localfile);
                canUpdate = !remoteMd5.Equals(localMd5);
                if (canUpdate) File.Delete(localfile);
            }
            if (canUpdate)
            {   //本地缺少文件
                message = "downloading>>" + fileUrl;
                AppFacade.Instance.SendMessageCommand(NotiConst.UPDATE_MESSAGE, message);
                BeginDownload(fileUrl, localfile);
                while (!(IsDownOK(localfile))) { yield return new WaitForEndOfFrame(); }
            }
        }
        yield return new WaitForEndOfFrame();
        OnResourceInited();
        message = "更新完成!!";
        Invoke("OnUpdateFinsh", 0.08f);
        www.Dispose();
        www = null;
        //AppFacade.Instance.SendMessageCommand(NotiConst.UPDATE_FINISHED, message);

    }

    void OnUpdateFailed()
    {
        string message = "更新失败!>";
        AppFacade.Instance.SendMessageCommand(NotiConst.UPDATE_MESSAGE, message);
    }

    /// <summary>
    /// 是否下载完成
    /// </summary>
    bool IsDownOK(string file)
    {
        return downloadFiles.Contains(file);
    }

    /// <summary>
    /// 线程下载
    /// </summary>
    void BeginDownload(string url, string file)
    {

        //线程下载
        object[] param = new object[2] { url, file };

        ThreadEvent ev = new ThreadEvent();
        ev.Key = NotiConst.UPDATE_DOWNLOAD;
        ev.evParams.AddRange(param);
        AppFacade.Instance.GetManager<ThreadManager>(ManagerName.Thread).AddEvent(ev, OnThreadCompleted);   //线程下载
    }


    /// <summary>
    /// 线程完成
    /// </summary>
    /// <param name="data"></param>
    void OnThreadCompleted(NotiData data)
    {
        switch (data.evName)
        {
            case NotiConst.UPDATE_EXTRACT:  //解压一个完成
                //
                break;
            case NotiConst.UPDATE_DOWNLOAD: //下载一个完成
                downloadFiles.Add(data.evParam.ToString());
                break;
        }
    }

    /// <summary>
    /// 资源初始化结束
    /// </summary>
    public void OnResourceInited()
    {
        if (AppConst.PublishMode)
        {
            AppFacade.Instance.GetManager<AssetsLoaderManager>(ManagerName.AssetsLoader).Initialize(AppConst.AssetDir, delegate()
            {
                Util.Log("Game", "Initialize OK!!!");
                this.OnInitialize();
            });
        }
        else
        {
            this.OnInitialize();
        }
#if SYNC_MODE
        AppFacade.Instance.GetManager<AssetsLoaderManager>(ManagerName.AssetsLoader).Initialize();
        this.OnInitialize();
#endif

    }

    void OnInitialize()
    {
        LuaManager lurMgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
        lurMgr.InitStart();
        lurMgr.DoFile("Game");         //加载游戏

        initialize = true;

        // 启动游戏逻辑
        Util.CallMethod("Game", "OnInitOK");     //初始化完成
        LogFilter.Instance().Init();
        //LogCenter.Instance().Init();
    }

    public void LogHandler(string message, string stacktrace, UnityEngine.LogType type)
    {
        StringBuilder s = new StringBuilder();
        s.Append(message);
        s.Append("\r\n");
        if (type == UnityEngine.LogType.Error || type == UnityEngine.LogType.Exception)
        {
            s.Append(stacktrace);
            LogCenter.LogError(s.ToString());
        }
        else if (type == UnityEngine.LogType.Log)
        {
            LogCenter.Log(s.ToString());
        }
        else if (type == UnityEngine.LogType.Warning)
        {
            LogCenter.LogWarning(s.ToString());
        }
    }

    /// <summary>
    /// 析构函数
    /// </summary>
    void OnDestroy()
    {
        LuaManager lurMgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
        if (lurMgr != null)
        {
            lurMgr.Close();
        }
        if (AppFacade.Instance.networkManager != null)
        {
            AppFacade.Instance.networkManager.Close();
        }
        LogCenter.Instance().Close();

        Util.Log("Game", "~Main was destroyed");
    }
}

