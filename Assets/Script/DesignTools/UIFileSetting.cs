using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using System;

public class UIFileSetting : UIDialogBase
{

    public delegate void fuc(string dir);
    private static UIFileSetting instance;
    private Text Title;
    private Button ButtonExit;
    private Image Icon;
    private InputField FileDir;
    private Button FileBnt;
    private Button CancelBnt;

    void Awake()
    {
        instance = this;
        Title = transform.FindChild("Dialog/Title").GetComponent<Text>();
        FileDir = transform.FindChild("Dialog/InputField").GetComponent<InputField>();
        Transform BntTra = transform.FindChild("Dialog/Button");
        FileBnt = BntTra.GetComponent<Button>();
        CancelBnt = transform.FindChild("Dialog/CancelBnt").GetComponent<Button>();
        
        CancelBnt.onClick.AddListener(delegate ()
        {
            _Hide();
        });
        gameObject.SetActive(false);
        
    }

    void InitTitle(string title)
    {
        Title.text = title;
        if (!string.IsNullOrEmpty(MapDesignTools.instance.FilePath))
        {
            FileDir.text = MapDesignTools.instance.FilePath;
        }
        else
        {
            FileDir.text = @"D:\MapFiles\file.csv";
        }
    }


    void SetOperation(fuc kfuc)
    {
        FileBnt.onClick.RemoveAllListeners();
        FileBnt.onClick.AddListener(delegate ()
        {
            kfuc(FileDir.text);
            MapDesignTools.instance.FilePath = FileDir.text;
            _Hide();
        });
    }


    public static void  Show(string title)
    {
        instance.InitTitle(title);
        instance.ShowProcess();
    }

    public static void SetOpera(fuc kfuc)
    {
        instance.SetOperation(kfuc);
    }

}
