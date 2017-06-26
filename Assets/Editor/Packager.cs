using UnityEditor;
using UnityEngine;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;

public class Packager
{
    public enum PackagerResType
    {
        eALLRES,
        eLUA,
        eSCENE,
        eCHARACTER,
        eUI,
    }
    public static string platform = string.Empty;
    static List<string> paths = new List<string>();
    static List<string> files = new List<string>();
    static List<AssetBundleBuild> maps = new List<AssetBundleBuild>();
    static BuildTarget target = BuildTarget.StandaloneWindows;
    ///-----------------------------------------------------------
    static string[] exts = { ".txt", ".xml", ".lua", ".assetbundle", ".json" };

   // 载入素材
   // </summary>
    static UnityEngine.Object LoadAsset(string file)
    {
        if (file.EndsWith(".lua")) file += ".txt";
        return AssetDatabase.LoadMainAssetAtPath("Assets/Data/" + file);
    }



    [MenuItem("BuildClient/BuildALLRes/Build iPhone Resource", false, 100)]
    public static void BuildiPhoneResource() {
#if UNITY_IOS
        
#if UNITY_5
        target = BuildTarget.iOS;
#else
        target = BuildTarget.iPhone;
#endif
        BuildAssetResource(target);
#endif
    }

    [MenuItem("BuildClient/BuildALLRes/Build Android Resource", false, 101)]
    public static void BuildAndroidResource() {
#if UNITY_ANDROID
        target = BuildTarget.Android;
        BuildAssetResource(BuildTarget.Android);
#endif
    }

    [MenuItem("BuildClient/BuildALLRes/Build Windows Resource", false, 102)]
    public static void BuildWindowsResource() {
#if UNITY_STANDALONE
        target = BuildTarget.StandaloneWindows;
        BuildAssetResource(BuildTarget.StandaloneWindows);
#endif
    }

    [MenuItem("BuildClient/BuildRes/Build Windows Resource/Build Lua", false, 102)]
    public static void BuildWindowsResourceLua()
    {
#if UNITY_STANDALONE
        BuildAssetResource(BuildTarget.StandaloneWindows,PackagerResType.eLUA);
#endif
    }

    [MenuItem("BuildClient/BuildRes/Build Windows Resource/Build Scene", false, 102)]
    public static void BuildWindowsResourceScene()
    {
#if UNITY_STANDALONE
        BuildAssetResource(BuildTarget.StandaloneWindows, PackagerResType.eSCENE);
#endif
    }

    [MenuItem("BuildClient/BuildRes/Build Windows Resource/Build character", false, 102)]
    public static void BuildWindowsResourceCharacter()
    {
#if UNITY_STANDALONE
        BuildAssetResource(BuildTarget.StandaloneWindows, PackagerResType.eCHARACTER);
#endif
    }

    [MenuItem("BuildClient/BuildRes/Build Windows Resource/Build UI", false, 102)]
    public static void BuildWindowsResourceUI()
    {
#if UNITY_STANDALONE
        BuildAssetResource(BuildTarget.StandaloneWindows, PackagerResType.eUI);
#endif
    }

    /// <summary>
    /// 生成绑定素材
    /// </summary>
    public static void BuildAssetResource(BuildTarget target, PackagerResType pRtype = PackagerResType.eALLRES)
    {
        if (Directory.Exists(Util.DataPath))
        {
            Directory.Delete(Util.DataPath, true);
        }
        string streamPath = Application.streamingAssetsPath;
        if (Directory.Exists(streamPath))
        {
            Directory.Delete(streamPath, true);
        }
        Directory.CreateDirectory(streamPath);
        AssetDatabase.Refresh();
        string Serverpath = Application.dataPath + "/PublishRes/" + AppConst.PublishServerList;
        string outServerpath = streamPath +"/" + AppConst.PublishServerList;
        File.Copy(Serverpath, outServerpath, true);
        ClearAssetBundlesName();
        maps.Clear();
        if(pRtype == PackagerResType.eALLRES|| pRtype == PackagerResType.eLUA)
           HandleLuaBundle();

        if(pRtype == PackagerResType.eALLRES)
           HandleResourceBundle();
        else if (pRtype == PackagerResType.eSCENE)
           HandleResourceBundle(EResType.eResScene);
        else if(pRtype == PackagerResType.eCHARACTER)
        {
            HandleResourceBundle(EResType.eResMonster);
            HandleResourceBundle(EResType.eResPet);
            HandleResourceBundle(EResType.eResBoss);
            HandleResourceBundle(EResType.eResCharacter);
        }
        else if (pRtype == PackagerResType.eUI)
        {
            HandleResourceBundle(EResType.eResUI);
        }


        string resPath = "Assets/" + AppConst.AssetDir;
        BuildAssetBundleOptions options = BuildAssetBundleOptions.DeterministicAssetBundle | 
                                          BuildAssetBundleOptions.ChunkBasedCompression;

        BuildPipeline.BuildAssetBundles(resPath, maps.ToArray(), options, target);
        BuildFileIndex();


        string streamDir = Application.dataPath + "/" + AppConst.LuaTempDir;
        if (Directory.Exists(streamDir)) Directory.Delete(streamDir, true);
       

        for (int i = 0; i < (int)EResType.eResCount; i++)
        {
            EResType kResGroup = (EResType)i;
            if (kResGroup == EResType.eResFont || kResGroup == EResType.eResLua || kResGroup == EResType.eResShader
            || kResGroup == EResType.eResScene || kResGroup == EResType.eResPicture || kResGroup == EResType.eSceneLoadRes) continue;
           string path = ResDefine.GetResPath(kResGroup);
           if (Directory.Exists(path)) Directory.Delete(path, true); //打包完成删除源资源
        }
        AssetDatabase.Refresh();

    }

    static void AddBuildMap(string bundleName, List<string> pattern, string path) {
        // string[] files = Directory.GetFiles(path, pattern);
        
        ArrayList ArraryFiles = ResDefine.GetResourceFiles(path, pattern);
        
        if (ArraryFiles.Count == 0) return;
        string[] files = new string[ArraryFiles.Count];
        ArraryFiles.CopyTo(files);
        for (int i = 0; i < files.Length; i++)
        {
            files[i] = files[i].Replace('\\', '/');
        }
        AssetBundleBuild build = new AssetBundleBuild();
        build.assetBundleName = bundleName;
        build.assetNames = files;
        maps.Add(build);
    }

    /// <summary>
    /// 处理Lua代码包
    /// </summary>
    static void HandleLuaBundle() {
        string streamDir = Application.dataPath + "/" + AppConst.LuaTempDir;
        if (!Directory.Exists(streamDir)) Directory.CreateDirectory(streamDir);

        string[] srcDirs = { CustomSettings.luaDir, CustomSettings.FrameworkPath + "/ToLua/Lua" };
        for (int i = 0; i < srcDirs.Length; i++) {
            if (AppConst.LuaByteMode) {
                string sourceDir = srcDirs[i];
                string[] files = Directory.GetFiles(sourceDir, "*.lua", SearchOption.AllDirectories);
                int len = sourceDir.Length;

                if (sourceDir[len - 1] == '/' || sourceDir[len - 1] == '\\') {
                    --len;
                }
                for (int j = 0; j < files.Length; j++) {
                    string str = files[j].Remove(0, len);
                    string dest = streamDir + str + ".bytes";
                    string dir = Path.GetDirectoryName(dest);
                    Directory.CreateDirectory(dir);
                    EncodeLuaFile(files[j], dest);
                }    
            } else {
                ToLuaMenu.CopyLuaBytesFiles(srcDirs[i], streamDir);
            }
        }
        string[] dirs = Directory.GetDirectories(streamDir, "*", SearchOption.AllDirectories);
        for (int i = 0; i < dirs.Length; i++) {
            string name = dirs[i].Replace(streamDir, string.Empty);
            name = name.Replace('\\', '_').Replace('/', '_');
            name = "lua/lua_" + name.ToLower() + ResDefine.ExtName;

            string path = "Assets" + dirs[i].Replace(Application.dataPath, "");
            AddBuildMap(name,  new List<string> { "bytes" }, path);
        }
        AddBuildMap("lua/lua" + ResDefine.ExtName, new List<string> { "bytes" }, "Assets/" + AppConst.LuaTempDir);

        //-------------------------------处理非Lua文件----------------------------------
        string luaPath = AppDataPath + "/StreamingAssets/lua/";
        for (int i = 0; i < srcDirs.Length; i++) {
            paths.Clear(); files.Clear();
            string luaDataPath = srcDirs[i].ToLower();
            Recursive(luaDataPath);
            foreach (string f in files) {
                if (f.EndsWith(".meta") || f.EndsWith(".lua")) continue;
                string newfile = f.Replace(luaDataPath, "");
                string path = Path.GetDirectoryName(luaPath + newfile);
                if (!Directory.Exists(path)) Directory.CreateDirectory(path);

                string destfile = path + "/" + Path.GetFileName(f);
                File.Copy(f, destfile, true);
            }
        }
        AssetDatabase.Refresh();
    }


    static void HandleResourceBundle(EResType eResType)
    {
        EResType kResGroup = eResType;
        string path = ResDefine.GetResPath(kResGroup);
        if (string.IsNullOrEmpty(path) || !Directory.Exists(path)) return;
        string ResName = ResDefine.GetResourceType(kResGroup);
        string ResFolderName = ResName + "/";
        string Dirpath = "";

        List<string> kExtList = new List<string>();
        ResDefine.GetResTypeFileExtList(kResGroup, ref kExtList);


        string[] dirs = Directory.GetDirectories(path, "*", SearchOption.AllDirectories);
        for (int j = 0; j < dirs.Length; j++)
        {
            string fPath = path;
            if (target == BuildTarget.iOS )
                fPath = path + "/";
            string name = dirs[j].Replace(fPath, string.Empty).TrimStart(new char[] { '\\' });
            name = name.Replace('\\', '_').Replace('/', '_');
            name = name.ToLower() + ResDefine.ExtName;

            Dirpath = "Assets" + dirs[j].Replace(Application.dataPath, "");
            AddBuildMap(ResFolderName + name, kExtList, Dirpath);
        }
        if (kResGroup != EResType.eResScene)  //资源根目录打包
        {
            string DirName = Path.GetFileName(path);
            AddBuildMap(ResFolderName + DirName + ResDefine.ExtName, kExtList, "Assets" + path.Replace(Application.dataPath, ""));
        }

     


    }
    /// <summary>
    /// 处理资源assetbundle
    /// </summary>
    static void HandleResourceBundle()
    {
        string resPath = AppDataPath + "/" + AppConst.AssetDir + "/";
        if (!Directory.Exists(resPath))
            Directory.CreateDirectory(resPath);

        for (int i = 0; i < (int)EResType.eResCount; i++)
        {
            EResType kResGroup = (EResType)i;
            if (kResGroup != EResType.eResScene&&kResGroup!= EResType.eSceneLoadRes) 
                HandleResourceBundle(kResGroup);
        }

    }

    /// <summary>
    /// 处理Lua文件
    /// </summary>
    static void HandleLuaFile() {
        string resPath = AppDataPath + "/StreamingAssets/";
        string luaPath = resPath + "/lua/";

        //----------复制Lua文件----------------
        if (!Directory.Exists(luaPath)) {
            Directory.CreateDirectory(luaPath); 
        }
        string[] luaPaths = { AppDataPath + "/TLBY/lua/", 
                              AppDataPath + "/TLBY/Tolua/Lua/" };

        for (int i = 0; i < luaPaths.Length; i++) {
            paths.Clear(); files.Clear();
            string luaDataPath = luaPaths[i].ToLower();
            Recursive(luaDataPath);
            int n = 0;
            foreach (string f in files) {
                if (f.EndsWith(".meta")) continue;
                string newfile = f.Replace(luaDataPath, "");
                string newpath = luaPath + newfile;
                string path = Path.GetDirectoryName(newpath);
                if (!Directory.Exists(path)) Directory.CreateDirectory(path);

                if (File.Exists(newpath)) {
                    File.Delete(newpath);
                }
                if (AppConst.LuaByteMode) {
                    EncodeLuaFile(f, newpath);
                } else {
                    File.Copy(f, newpath, true);
                }
                UpdateProgress(n++, files.Count, newpath);
            } 
        }
        EditorUtility.ClearProgressBar();
        AssetDatabase.Refresh();
    }

    static void FileJasonBuild(List<ResInfo> resInfoList)
    {
        string FileList = AppConst.AssetDir + "/" + AppConst.PatchList;
        FilesConfig filelist = new FilesConfig();
        filelist.VerRevision = new VersionInfo();
        filelist.mShardInfos = resInfoList;
        filelist.PatchUrl = AppConst.PathWebUrl;
        filelist.VerRevision.Init(AppConst.VER_MAJOR, AppConst.VER_MINOR, AppConst.VER_REVISION);
        JsonHelp.SaveToJsonFile(filelist, FileList);
        AssetDatabase.Refresh();
       #if UNITY_STANDALONE || UNITY_ANDROID
        Process process = new Process();
        //设定程序名
        process.StartInfo.FileName = "cmd.exe";
        //关闭Shell的使用
        process.StartInfo.UseShellExecute = false;
        //重新定向标准输入，输入，错误输出
        process.StartInfo.RedirectStandardInput = true;
        process.StartInfo.RedirectStandardOutput = true;
        process.StartInfo.RedirectStandardError = true;
        //设置cmd窗口不显示
        process.StartInfo.CreateNoWindow = true;
        //开始
        process.Start();
        //输入命令，退出
        process.StandardInput.WriteLine(@"set SVN_PATH=D:\Program Files\TortoiseSVN\bin");
        process.StandardInput.WriteLine(@"set WORK_DIR=%cd% ");
        process.StandardInput.WriteLine(@"set VERSION_TEMPLATE=%cd%\Assets\" + FileList);
        process.StandardInput.WriteLine(@"set VERSION_RELEASE=%cd%\Assets\" + FileList);
        process.StandardInput.WriteLine(@"cd %SVN_PATH% ");
        process.StandardInput.WriteLine(@"SubWCRev.exe ""%WORK_DIR%"" ""%VERSION_TEMPLATE%"" ""%VERSION_RELEASE%"" ");
        //process.StandardInput.WriteLine("netstat");
        process.StandardInput.WriteLine("exit");
        string strRst = process.StandardOutput.ReadToEnd();
       #endif
    }

    static void BuildFileIndex() {
        string resPath = AppDataPath + "/StreamingAssets/";
        ///----------------------创建文件列表-----------------------
        string newFilePath = resPath + AppConst.PatchList;
        if (File.Exists(newFilePath)) File.Delete(newFilePath);

        paths.Clear(); files.Clear();
        Recursive(resPath);

        List<ResInfo> ResInfoList = new List<ResInfo>();
        ResInfo resInfo;
        for (int i = 0; i < files.Count; i++)
        {
            string file = files[i];
            string ext = Path.GetExtension(file);
            if (file.EndsWith(".meta") || file.Contains(".DS_Store")) continue;

            ResDefine.EncryptAssetbundle(file);
            string md5 = Util.md5file(file);
            string value = file.Replace(resPath, string.Empty);
            resInfo = new ResInfo();
            resInfo.ResName = value;
            resInfo.md5 = md5;

            ResInfoList.Add(resInfo);
        }
        
        FileJasonBuild(ResInfoList);
    }

    /// <summary>
    /// 数据目录
    /// </summary>
    static string AppDataPath {
        get { return Application.dataPath.ToLower(); }
    }

    /// <summary>
    /// 遍历目录及其子目录
    /// </summary>
    static void Recursive(string path) {
        string[] names = Directory.GetFiles(path);
        string[] dirs = Directory.GetDirectories(path);
        foreach (string filename in names) {
            string ext = Path.GetExtension(filename);
            if (ext.Equals(".meta")) continue;
            files.Add(filename.Replace('\\', '/'));
        }
        foreach (string dir in dirs) {
            if (dir.Contains(".svn"))
                continue;
            
            paths.Add(dir.Replace('\\', '/'));
            Recursive(dir);
        }
    }

    static void UpdateProgress(int progress, int progressMax, string desc) {
        string title = "Processing...[" + progress + " - " + progressMax + "]";
        float value = (float)progress / (float)progressMax;
        EditorUtility.DisplayProgressBar(title, desc, value);
    }

    public static void EncodeLuaFile(string srcFile, string outFile) {
        if (!srcFile.ToLower().EndsWith(".lua")) {
            File.Copy(srcFile, outFile, true);
            return;
        }

        bool isWin = true;
        string luaexe = string.Empty;
        string args = string.Empty;
        string exedir = string.Empty;
        string currDir = Directory.GetCurrentDirectory();
        if (Application.platform == RuntimePlatform.WindowsEditor) {
            isWin = true;
            luaexe = "luajit.exe";
            args = "-b " + srcFile + " " + outFile;
            exedir = AppDataPath.Replace("assets", "") + "LuaEncoder/luajit/";
        } else if (Application.platform == RuntimePlatform.OSXEditor) {
            isWin = false;
            luaexe = "./luac";
            args = "-o " + outFile + " " + srcFile;
            exedir = AppDataPath.Replace("assets", "") + "LuaEncoder/luavm/";
        }
        Directory.SetCurrentDirectory(exedir);
        ProcessStartInfo info = new ProcessStartInfo();
        info.FileName = luaexe;
        info.Arguments = args;
        info.WindowStyle = ProcessWindowStyle.Hidden;
        info.ErrorDialog = true;
        info.UseShellExecute = isWin;
        Debugger.Log(info.FileName + " " + info.Arguments);

        Process pro = Process.Start(info);
        pro.WaitForExit();
        Directory.SetCurrentDirectory(currDir);
    }

    [MenuItem("BuildClient/Build Protobuf-lua-gen File")]
    public static void BuildProtobufFile() {
        //if (!AppConst.ExampleMode) {
        //    Debugger.LogError("若使用编码Protobuf-lua-gen功能，需要自己配置外部环境！！");
        //    return;
        //}
        string dir = AppDataPath + "/Lua/3rd/pblua";
        paths.Clear(); files.Clear(); Recursive(dir);

        string protoc = "d:/protobuf-2.4.1/src/protoc.exe";
        string protoc_gen_dir = "\"d:/protoc-gen-lua/plugin/protoc-gen-lua.bat\"";

        foreach (string f in files) {
            string name = Path.GetFileName(f);
            string ext = Path.GetExtension(f);
            if (!ext.Equals(".proto")) continue;

            ProcessStartInfo info = new ProcessStartInfo();
            info.FileName = protoc;
            info.Arguments = " --lua_out=./ --plugin=protoc-gen-lua=" + protoc_gen_dir + " " + name;
            info.WindowStyle = ProcessWindowStyle.Hidden;
            info.UseShellExecute = true;
            info.WorkingDirectory = dir;
            info.ErrorDialog = true;
            Debugger.Log(info.FileName + " " + info.Arguments);

            Process pro = Process.Start(info);
            pro.WaitForExit();
        }
        AssetDatabase.Refresh();
    }

    static void ClearAssetBundlesName()
    {
        int length = AssetDatabase.GetAllAssetBundleNames().Length;
   
        string[] oldAssetBundleNames = new string[length];
        for (int i = 0; i < length; i++)
        {
            oldAssetBundleNames[i] = AssetDatabase.GetAllAssetBundleNames()[i];
        }

        for (int j = 0; j < oldAssetBundleNames.Length; j++)
        {
            AssetDatabase.RemoveAssetBundleName(oldAssetBundleNames[j], true);
        }
        length = AssetDatabase.GetAllAssetBundleNames().Length;
    }

    static string Replace(string s)
    {
        return s.Replace("\\", "/");
    }

    static void file(string source)
    {
        string _source = Replace(source);
        string _assetPath = "Assets" + _source.Substring(Application.dataPath.Length);
        string _assetPath2 = _source.Substring(Application.dataPath.Length + 1);
        //Debug.Log (_assetPath);

        //在代码中给资源设置AssetBundleName
        AssetImporter assetImporter = AssetImporter.GetAtPath(_assetPath);
        string assetName = _assetPath2.Substring(_assetPath2.IndexOf("/") + 1);
        assetName = assetName.Replace(Path.GetExtension(assetName), ".unity3d");
        //Debug.Log (assetName);
        assetImporter.assetBundleName = assetName;
    }

    static void Pack(string source)
    {
        DirectoryInfo folder = new DirectoryInfo(source);
        FileSystemInfo[] files = folder.GetFileSystemInfos();
        int length = files.Length;
        for (int i = 0; i < length; i++)
        {
            if (files[i] is DirectoryInfo)
            {
                Pack(files[i].FullName);
            }
            else
            {
                if (!files[i].Name.EndsWith(".meta"))
                {
                    file(files[i].FullName);
                }
            }
        }
    }
}