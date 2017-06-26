using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using PsdLayoutTool;
using System.Linq;
using System;

public class PictureUtil : Singleton<PictureUtil>
{

    #region delete repeat sprite

    List<string> allPngFiles = new List<string>();
    Dictionary<GameObject, List<Image>> allPngRefrences = new Dictionary<GameObject, List<Image>>();
    Dictionary<string, Png> allPngs = new Dictionary<string, Png>();

    public List<string> AllPngFiles
    {
        get
        {
            return allPngFiles;
        }
    }

    public Dictionary<GameObject, List<Image>> AllPngRefrences
    {
        get
        {
            return allPngRefrences;
        }
    }
    
    public string GetRelativePath(string fullPath)
    {
        return PsdImporter.GetRelativePath(fullPath);
    }
    public string GetFullPath(string assetPath)
    {
        string fullname = PsdImporter.GetFullProjectPath() + assetPath;
        return fullname;
    }
    public string PrefabPath
    {
        get
        {
            return PsdImporter.prefabPath;
        }
    }
    public static string[] CheckDir
    {
        get
        {
            return PsdImporter.checkDir;
        }
    }

    //private string texturePath
    //{
    //    get
    //    {
    //        return PsdImporter.texturePath;
    //    }
    //}

    private bool IsSameSpriteFile(string file1, string file2)
    {
        if (!File.Exists(file1) || !File.Exists(file2))
        {
            return false;
        }
        //string relName1 = GetRelativePath(file1);
        //Texture2D tex1 = (Texture2D)AssetDatabase.LoadAssetAtPath(relName1, typeof(Texture2D));

        //string relName2 = GetRelativePath(file2);
        //Texture2D tex2 = (Texture2D)AssetDatabase.LoadAssetAtPath(relName2, typeof(Texture2D));

        //return IsSameSprite(tex1, tex2);

        return PngUtil.IsSamePng(file1, file2);
    }

    // 判定是否是同一张图片
    private bool IsSameSprite(Texture2D tex1, Texture2D tex2)
    {
        if (tex1.width != tex2.width || tex1.height != tex2.height)
        {
            return false;
        }
        byte[] bytes = tex1.EncodeToPNG();
        
        for (int w = 0; w < tex1.width; w += 15)
        {
            for (int h = 0; h < tex1.height; h += 15)
            {
                Color c1 = tex1.GetPixel(w, h);
                Color c2 = tex2.GetPixel(w, h);
                if (!c1.Equals(c2))
                {
                    return false;
                }
            }
        }
        return true;
    }

    private bool IsSameSpriteMd5File(string file1, string file2)
    {
        if (!File.Exists(file1) || !File.Exists(file2))
        {
            return false;
        }
        string m1 = Util.md5file(file1);
        string m2 = Util.md5file(file2);
        return m1.Equals(m2);
    }

    // 替换prefab中重复的资源
    public void ResetPrefabSpite(string newSprie, string oldSprite)
    {
        foreach (KeyValuePair<GameObject, List<Image>> kv in allPngRefrences)
        {
            GameObject go = kv.Key;
            List<Image> imgs = kv.Value;
            for (int j = 0; j < imgs.Count; j++)
            {
                if ((imgs[j].sprite.ToString() != "null"))
                {
                    string spritePath = AssetDatabase.GetAssetPath(imgs[j].sprite);
                    if (spritePath == oldSprite)
                    {
                        imgs[j].sprite = (Sprite)AssetDatabase.LoadAssetAtPath(newSprie, typeof(Sprite));
                        EditorUtility.SetDirty(go);
                    }
                }
            }
        }
    }

    public void DeleteSprite(string deleteAssetName)
    {
        AssetDatabase.DeleteAsset(deleteAssetName);
    }

    public string RenameSprite(string oldAssetName, string newAssetName)
    {
        //if(File.Exists(renameFile))
        {
            //string relFile = GetRelativePath(renameFile);
            //string relNewFile = GetRelativePath(newName);
            string ret = AssetDatabase.RenameAsset(oldAssetName, newAssetName);
            return ret;
        }
        //return "文件不存在";
    }
    // 获取gameobject中T类型的组件
    private List<T> GetObjectDependencies<T>(GameObject go)
    {
        List<T> results = new List<T>();
        UnityEngine.Object[] roots = new UnityEngine.Object[] { go };
        UnityEngine.Object[] dependObjs = EditorUtility.CollectDependencies(roots);
        foreach (UnityEngine.Object dependObj in dependObjs)
        {
            if (dependObj != null && dependObj.GetType() == typeof(T))
            {
                results.Add((T)System.Convert.ChangeType(dependObj, typeof(T)));
            }
        }

        return results;
    }

    public void CollectAllPngFiles()
    {
        allPngFiles.Clear();
        allPngs.Clear();

        for (int i = 0; i < CheckDir.Length; i++)
        {
            string checkPath = CheckDir[i];
            getAllFiles(checkPath);
        }
        EditorUtility.ClearProgressBar();
    }
    public void CollectRefrences()
    {
        allPngRefrences.Clear();
        string assetPrefabPath = GetRelativePath(PrefabPath);
        string[] guids = AssetDatabase.FindAssets("t:prefab", new string[] { assetPrefabPath });
        for (int i = 0; i < guids.Length; i++)
        {
            string path = AssetDatabase.GUIDToAssetPath(guids[i]);
            GameObject go = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            List<Image> imgs = GetObjectDependencies<Image>(go);
            allPngRefrences.Add(go, imgs);
            EditorUtility.DisplayProgressBar("collecting pic refrence info...", "正在收集pic引用信息..", (float)i / guids.Length);
        }
        EditorUtility.ClearProgressBar();
    }
    void getAllFiles(string path)
    {
        if (Directory.Exists(path))
        {
            string[] files = Directory.GetFiles(path, "*.png");
            for (int j = 0; j < files.Length; j++)
            {
                string fullName = files[j].Replace("\\", "/");
                allPngFiles.Add(fullName);
                if(!allPngs.ContainsKey(fullName))
                {
                    try
                    {
                        Png p = new Png(fullName);
                        allPngs.Add(fullName, p);
                    }
                    catch (Exception e)
                    {
                        Debug.Log("error on file:" + fullName + "; " + e.Message);
                    }
                }

                EditorUtility.DisplayProgressBar("collecting pic info...", "正在收集pic信息..", (float)j / files.Length);
            }

            string[] directories = Directory.GetDirectories(path);
            for (int i = 0; i < directories.Length; i++)
            {
                getAllFiles(directories[i]);
            }
        }
    }
    public long GetFileLength(string file)
    {
        if (File.Exists(file))
        {
            FileInfo fileInfo = new FileInfo(file);
            return fileInfo.Length;
        }
        return 0;
    }

    public void Clear()
    {
        allPngFiles.Clear();
        allPngRefrences.Clear();
        allPngs.Clear();
    }

    public void Save()
    {
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        CollectAllPngFiles();
        CollectRefrences();
    }

    string findCommonSprite(string fullname)
    {
        string name = Path.GetFileNameWithoutExtension(fullname);
        for (int j = allPngFiles.Count - 1; j >= 0; j--)
        {
            string file = allPngFiles[j];
            if (file.Contains("/Common/"))
            {
                string com_name = Path.GetFileNameWithoutExtension(file);
                if(name == com_name)
                {
                    return file;
                }
            }
        }
        return null;
    }

    public List<string> GetSameSprite(string fullName)
    {
        List<string> sameFileList = new List<string>();
        if(!allPngs.ContainsKey(fullName))
        {
            return sameFileList;
        }
        Png p = allPngs[fullName];
        string[] keys = allPngs.Keys.ToArray();
        for (int i = 0; i < keys.Length; i++)
        {
            string file = keys[i];
            if(file.Equals(fullName))
            {
                continue;
            }
            Png p2 = allPngs[file];
            if (PngUtil.IsSamePng(p, p2))
            {
                sameFileList.Add(file);
            }
        }
        return sameFileList;
    }
    public void DeleteRepeatCommonSprite()
    {
        List<string> com_files = new List<string>();
        List<string> dele_files = new List<string>();
        for (int i = allPngFiles.Count - 1; i >= 0; i--)
        {
            string file = allPngFiles[i];
            if (file.Contains("com_") && !file.Contains("/Common/")) //非common目录下的common图片
            {
                string com_file = findCommonSprite(file);
                if (!string.IsNullOrEmpty(com_file))
                {
                    com_files.Add(com_file);
                    dele_files.Add(file);
                }
            }
        }
        for (int i = 0; i < dele_files.Count; i++)
        {
            ResetPrefabSpite(GetRelativePath(com_files[i]), GetRelativePath(dele_files[i]));
        }
        for (int i = 0; i < dele_files.Count; i++)
        {
            DeleteSprite(GetRelativePath(dele_files[i]));
        }
        Save();
        Debug.Log("over");
    }
    #endregion
}


public class PictureEditor : EditorWindow
{
    PictureUtil _util;
    PictureUtil util
    {
        get
        {
            if (_util == null)
            {
                _util = PictureUtil.Instance();
            }
            return _util;
        }
    }
    void moveSelect(int step)
    {
        if (selectIndex < 0)
        {
            return;
        }
        for (int i = selectIndex + step; i < util.AllPngFiles.Count && i >= 0; i += step)
        {
            string file = util.AllPngFiles[i];
            if (string.IsNullOrEmpty(key) || file.ToLower().Contains(key.ToLower()))
            {
                selectIndex = i;
                return;
            }
        }
    }
    void OnDestroy()
    {
        util.Clear();
    }


    Vector2 scrollPos;
    Vector2 scrollPosRef;
    Vector3 mayRepeatePos;

    int modelID;
    string repFile1, repFile2;
    string key = "";
    int selectIndex = -1;
    enum EditType
    {
        None = 0,
        Replace = 1,
        Delete = 2,
        Rename = 3,
    }
    EditType curType = EditType.None;

    int replaceIndex = -1;
    string newName = "";

    string checkRepeatFile = "";
    List<string> sameFileList = new List<string>();
    int selectRepeatIndex = -1;
    void OnGUI()
    {
        if (util.AllPngFiles.Count == 0)
        {
            util.CollectAllPngFiles();
        }
        if (util.AllPngRefrences.Count == 0)
        {
            util.CollectRefrences();
        }
        if (Event.current.keyCode == KeyCode.UpArrow && Event.current.type == EventType.keyUp)
        {
            moveSelect(-1);
            Repaint();
        }
        else if (Event.current.keyCode == KeyCode.DownArrow && Event.current.type == EventType.keyUp)
        {
            moveSelect(1);
            Repaint();
        }

        EditorGUILayout.BeginHorizontal();

        int listWidth = 500;
        #region 图片列表
        EditorGUILayout.BeginVertical();
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("搜一下", GUILayout.Width(50));
        key = EditorGUILayout.TextField(key, GUILayout.Width(200));
        if (GUILayout.Button("删除所有与Common重复的图片"))
        {
            util.DeleteRepeatCommonSprite();
        }
        EditorGUILayout.EndHorizontal();
        // draw list
        scrollPos = EditorGUILayout.BeginScrollView(scrollPos, GUILayout.Width(listWidth), GUILayout.Height(Screen.height - 50));
        for (int i = 0; i < util.AllPngFiles.Count; i++)
        {
            string file = util.AllPngFiles[i];
            //string shortName = Path.GetFileNameWithoutExtension(file);
            if(string.IsNullOrEmpty(key) || file.ToLower().Contains(key.ToLower()))
            {
                string relName = util.GetRelativePath(file);
                GUIStyle style = EditorStyles.label;
                if (selectIndex == i)
                {
                    style = EditorStyles.boldLabel;
                }
                if (GUILayout.Button(relName, style))
                {
                    if(curType == EditType.None)
                    {
                        selectIndex = i;
                        selectRepeatIndex = -1;
                    }
                    else if(curType == EditType.Replace)
                    {
                        replaceIndex = i;
                    }
                }
            }
        }
        GUILayout.EndScrollView();
        EditorGUILayout.EndVertical();
        #endregion

        GUILayout.Box(string.Empty, GUILayout.Height(Screen.height), GUILayout.Width(1));
        //GUILayout.Space(listWidth);
        #region 选择图片的信息
        EditorGUILayout.BeginVertical(); // 垂直绘制
        GUILayout.Box(string.Empty, GUILayout.Height(1), GUILayout.Width(Screen.width)); // 横线
        GUILayout.Space(10);

        if (selectIndex >= 0 && util.AllPngFiles.Count > selectIndex)
        {
            #region 显示信息 height = 300
            int selectSize = 300;
            string file = util.AllPngFiles[selectIndex];
            string relName = util.GetRelativePath(file);
            Texture2D tex = (Texture2D)AssetDatabase.LoadAssetAtPath(relName, typeof(Texture2D));
            int w = tex.width;
            int h = tex.height;
            int max = w > h ? w : h;
            if (max > selectSize)
            {
                float scale = ((float)max) / selectSize;
                w = (int)(w / scale);
                h = (int)(h / scale);
            }
            GUI.DrawTexture(new Rect(listWidth + 5 + (selectSize - w) / 2, (selectSize + 10 - h) / 2, w, h), tex);
            GUILayout.Space(selectSize);
            GUILayout.Box(string.Empty, GUILayout.Height(1), GUILayout.Width(Screen.width));

            string len = "";
            double kb = ((double)util.GetFileLength(file)) / 1000;
            if(kb > 1024)
            {
                len = string.Format("{0:N}M", kb / 1024);
            }
            else
            {
                len = string.Format("{0:N}kb", kb);
            }
            GUILayout.Label(string.Format("大小：{0}x{1}      {2}", tex.width, tex.height, len));
            #endregion

            #region 引用信息
            int refrenceSize = 150;
            GUILayout.Space(10);
            GUILayout.Box(string.Empty, GUILayout.Height(1), GUILayout.Width(Screen.width));
            GUILayout.Label("引用列表：（注：prefab的重复次数表示该图片在prefab的引用次数）");
            scrollPosRef = EditorGUILayout.BeginScrollView(scrollPosRef, GUILayout.Width(500), GUILayout.Height(refrenceSize)); //  
            
            int refCount = 0;
            foreach (KeyValuePair<GameObject, List<Image>> kv in util.AllPngRefrences)
            {
                GameObject go = kv.Key;
                List<Image> imgs = kv.Value;
                for (int j = 0; j < imgs.Count; j++)
                {
                    if ((imgs[j].sprite.ToString() != "null"))
                    {
                        string spritePath = AssetDatabase.GetAssetPath(imgs[j].sprite);
                        if (spritePath == relName)
                        {
                            GUILayout.Label(AssetDatabase.GetAssetPath(go));
                            refCount++;
                        }
                    }
                }
            }
            GUILayout.EndScrollView();
            #endregion

            #region 可能重复的列表 height 200
            if(checkRepeatFile != file)
            {
                sameFileList = util.GetSameSprite(file);
            }
            int mayRepHeight = 100;
            GUILayout.Box(string.Empty, GUILayout.Height(1), GUILayout.Width(Screen.width));
            GUILayout.Label("可能与之重复的图片:");
            mayRepeatePos = EditorGUILayout.BeginScrollView(mayRepeatePos, GUILayout.Width(400), GUILayout.Height(mayRepHeight));
            string repeatFile = "";
            string relRepeatName = "";
            for (int i = 0; i < sameFileList.Count; i++)
            {
                repeatFile = sameFileList[i];
                relRepeatName = util.GetRelativePath(repeatFile);
                GUIStyle style = EditorStyles.label;
                if (selectRepeatIndex == i)
                {
                    style = EditorStyles.boldLabel;
                }
                if (GUILayout.Button(relRepeatName, style))
                {
                    selectRepeatIndex = i;
                }
            }
            GUILayout.EndScrollView();

            EditorGUILayout.BeginHorizontal();
            if(curType == EditType.None)
            {
                if(relRepeatName != "")
                {
                    if (GUILayout.Button("重置并删除选择项", GUILayout.Width(150)))
                    {
                        string s = string.Format("'{0}'将被替换成'{1}',确定继续吗?", relRepeatName, relName);
                        bool b = EditorUtility.DisplayDialog("提示", s, "确定", "取消");
                        if (b)
                        {
                            util.ResetPrefabSpite(relName, relRepeatName);
                            util.DeleteSprite(relRepeatName);
                            util.Save();
                            relRepeatName = null;
                        }
                    }
                    if (GUILayout.Button("重置并删除所有项", GUILayout.Width(150)))
                    {
                        string s = string.Format("所有项将被替换成'{0}',确定继续吗?", relName);
                        bool b = EditorUtility.DisplayDialog("提示", s, "确定", "取消");
                        if (b)
                        {
                            for(int i = 0; i < sameFileList.Count; i++)
                            {
                                string relrepeatfile = util.GetRelativePath(sameFileList[i]);
                                util.ResetPrefabSpite(relName, relrepeatfile);
                            }
                            for (int i = 0; i < sameFileList.Count; i++)
                            {
                                string relrepeatfile = util.GetRelativePath(sameFileList[i]);
                                util.DeleteSprite(relrepeatfile);
                            }
                            util.Save();
                            relRepeatName = null;
                        }
                    }
                }                
            }
            
            EditorGUILayout.EndHorizontal();
            if (relRepeatName != "")
            {
                Texture2D texRepeat = (Texture2D)AssetDatabase.LoadAssetAtPath(relRepeatName, typeof(Texture2D));
                if(texRepeat != null)
                {
                    int repw = texRepeat.width;
                    int reph = texRepeat.height;
                    int repmax = repw > reph ? repw : reph;
                    if (repmax > mayRepHeight)
                    {
                        float scale = ((float)repmax) / mayRepHeight;
                        repw = (int)(repw / scale);
                        reph = (int)(reph / scale);
                    }
                    GUI.DrawTexture(new Rect(listWidth + 400 + 5 + (mayRepHeight - repw) / 2, (mayRepHeight - reph) / 2 + 250 + selectSize, repw, reph), texRepeat);
                    //GUI.DrawTexture(new Rect(400, 0, repw, reph), texRepeat);
                }
            }
            #endregion

            GUILayout.Space(10);
            GUILayout.Box(string.Empty, GUILayout.Height(1), GUILayout.Width(Screen.width));
            EditorGUILayout.BeginHorizontal();
            if (curType == EditType.None)
            {
                #region none
                if (GUILayout.Button("替换", GUILayout.Width(50)))
                {
                    curType = EditType.Replace;
                }
                if (GUILayout.Button("删除", GUILayout.Width(50)))
                {
                    curType = EditType.Delete;
                    string content = string.Format("确定要删除图片{0}吗？", relName);
                    if(refCount > 0)
                    {
                        content = string.Format("目前图片{0}还有{1}个引用，确定要删除吗？", relName, refCount);
                    }
                    bool b = EditorUtility.DisplayDialog("提示", content, "确定", "取消");
                    if (b)
                    {
                        util.DeleteSprite(relName);
                        util.Save();
                    }
                    curType = EditType.None;
                }
                if (GUILayout.Button("重命名 ", GUILayout.Width(50)))
                {
                    curType = EditType.Rename;
                }
                #endregion
            }
            else if (curType == EditType.Replace)
            {
                #region replace
                EditorGUILayout.BeginVertical();
                if (GUILayout.Button("取消替换", GUILayout.Width(100)))
                {
                    curType = EditType.None;
                    replaceIndex = -1;
                }
                
                if (replaceIndex >= 0 && util.AllPngFiles.Count > replaceIndex)
                {
                    int repSize = 200;
                    string repfile = util.AllPngFiles[replaceIndex];
                    string reprelName = util.GetRelativePath(repfile);
                    Texture2D reptex = (Texture2D)AssetDatabase.LoadAssetAtPath(reprelName, typeof(Texture2D));
                    int rw = reptex.width;
                    int rh = reptex.height;
                    int rmax = rw > rh ? rw : rh;
                    if (rmax > repSize)
                    {
                        float scale = ((float)rmax) / repSize;
                        rw = (int)(rw / scale);
                        rh = (int)(rh / scale);
                    }
                    GUI.DrawTexture(new Rect(((repSize - rw)/2) + listWidth + 5, ((repSize - rh)/2 + 450 + selectSize), rw, rh), reptex);
                    if(replaceIndex != selectIndex)
                    {
                        string rlen = "";
                        double rkb = ((double)util.GetFileLength(repfile)) / 1000;
                        if (rkb > 1024)
                        {
                            rlen = string.Format("{0:N}M", rkb / 1024);
                        }
                        else
                        {
                            rlen = string.Format("{0:N}kb", rkb);
                        }
                        GUILayout.Label(string.Format("已经选择{0}    大小：{1}x{2}      {3}", reprelName, reptex.width, reptex.height, rlen));
                        if (GUILayout.Button("确定", GUILayout.Width(100)))
                        {
                            string content = string.Format("工程里所有用到{0}的prefab资源都将替换成{1}，确定吗？", relName, reprelName);
                            bool b = EditorUtility.DisplayDialog("提示", content, "确定", "取消");
                            if (b)
                            {
                                curType = EditType.None;
                                replaceIndex = -1;
                                util.ResetPrefabSpite(reprelName, relName);
                                util.Save();
                            }
                        }
                    }
                }
                else
                {
                    GUILayout.Label("选择要替换的图片：", GUILayout.Width(200));
                }
                EditorGUILayout.EndVertical();
                #endregion
            }
            else if(curType == EditType.Delete) { }
            else if(curType == EditType.Rename)
            {
                #region rename
                if (GUILayout.Button("取消重命名", GUILayout.Width(100)))
                {
                    curType = EditType.None;                    
                }
                EditorGUILayout.BeginVertical();
                GUILayout.Label("旧："+ Path.GetFileNameWithoutExtension(relName));
                GUILayout.Label("新：", GUILayout.Width(30));
                if(newName == "")
                {
                    newName = Path.GetFileNameWithoutExtension(relName);
                }
                newName = EditorGUILayout.TextField(newName, GUILayout.Width(200));
                if (GUILayout.Button("确定", GUILayout.Width(100)))
                {
                    string ret = util.RenameSprite(relName, newName);
                    if(string.IsNullOrEmpty(ret))
                    {
                        // ok
                        util.Save();
                    }
                    else
                    {
                        EditorUtility.DisplayDialog("提示", ret, "确定");
                    }
                    curType = EditType.None;
                    newName = "";
                }
                EditorGUILayout.EndVertical();
                #endregion
            }

            EditorGUILayout.EndHorizontal();
        }
        //GUILayout.MaxWidth(Screen.width - 30)
        EditorGUILayout.EndVertical();
        #endregion


        EditorGUILayout.EndHorizontal();
    }

    [MenuItem("DesignTools/picture 编辑")]
    public static void DoWindow()
    {
        GetWindow<PictureEditor>("picture");
    }
}

