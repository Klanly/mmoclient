

using UnityEngine;
using System.Collections.Generic;
using LuaInterface;
using System.IO;
using System.Collections;
using System;
using System.Text;
using System.Linq;

public class LogFilter : Singleton<LogFilter>
{
    List<string> flags = new List<string>();

   
    public bool Init()
    {
        flags.Clear();
        object[] obj = Util.CallMethod("LogConfig", "GetLogFlags");
        if (obj == null || obj.Length == 0)
        {
            return false;
        }
        LuaTable flagsTable = obj[0] as LuaTable;
        object[] list = flagsTable.ToArray();

        for (int i = 0; i < list.Length; i++)
        {
            string f = list[i] as string;
            flags.Add(f);
        }
        if (!flags.Contains("Game"))
        {
            flags.Add("Game");
        }
        flagsTable.Dispose();

        //sb.Append("\r\n*************************************** start " + DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss") + " ***************************************\r\n");
        return true;
    }

    public void Close()
    {
        //sb.Append("\r\n*************************************** end " + DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss") + " ***************************************\r\n");
        flags.Clear();
        //write();
    }
    public void Log(string flag, string log)
    {
        if (flags.Contains(flag))
        {
            Debug.Log(log);
            //io(log);
        }
    }
    public void Warning(string flag, string log)
    {
        if (flags.Contains(flag))
        {
            Debug.LogWarning(log);
            //io(log);
        }
    }
    public void Error(string flag, string log)
    {
        if (flags.Contains(flag))
        {
            Debug.LogError(log);
            //io(log);
        }
    }
//    private void write()
//    {
//        string name = getFileName();
//        FileMode mode = FileMode.Create;
//        if (File.Exists(name))
//        {
//            mode = FileMode.Append;
//        }
//        FileStream fs = new FileStream(name, mode);
//        curFileLength = fs.Length + sb.Length;
//        StreamWriter sw = new StreamWriter(fs);
//        sw.Write(sb.ToString());
//        sw.Flush();
//        sw.Close();
//        fs.Close();
//        sb.Clear();
//    }

//    private void io(string log)
//    {
//#if UNITY_STANDALONE_WIN
//        sb.Append(log + "\r\n");
//        if (sb.Length + curFileLength > len)
//        {
//            write();
//        }
//#endif
//    }
//    
}
//using System.Collections.Generic;

// ��־����
//public enum LogType
//{
//    Normal = 0,     // ��ͨ
//    Warning,        // ����
//    Error,          // ����

//    Max,
//};

public struct LogTraceNode
{
    public byte type;  // �������
    public string msg;         // ����
}

public class LogCenter : Singleton<LogCenter>
{
    // ��־�б�
    Queue<LogTraceNode> m_LogList;

    // ��ǰ�������־�����ʽ
    LogTrace m_CurTrace;

    /// <summary>
    /// ���캯��
    /// </summary>
    public LogCenter()
    {
        m_CurTrace = null;
    }

    /// <summary>
    /// �ͷ�
    /// </summary>
    public void Release()
    {
        if (m_CurTrace != null)
        {
            m_CurTrace.Release();
            m_CurTrace = null;
        }
    }


    /// <summary>
    /// ����
    /// </summary>
    public void Update()
    {
        if (null != m_CurTrace)
            m_CurTrace.Update();
    }

    /// <summary>
    /// ��Main.cs������Ⱦ
    /// </summary>
    public void OnGUI()
    {
        if (null != m_CurTrace)
            m_CurTrace.OnGUI();
    }

    /// <summary>
    /// ѹ��һ����־ 
    /// </summary>
    public void Push(LogType type, string msg)
    {
        if (m_CurTrace != null)
        {
            LogTraceNode node;
            node.type = (byte)type;
            node.msg = msg;
            if (AppConst.logDebug)
            {
                m_CurTrace.AddLog(node); 
            }
            else if(type != LogType.Log)
            {
                m_CurTrace.AddLog(node); 
            }
           
        }
    }

    /// <summary>
    /// ��/�ر�һ��TRACE 
    /// </summary>
    public bool OpenTrace(LogTraceType type)
    {
        LogTrace newTrace = null;

        switch (type)
        {
            case LogTraceType.Screen:
                newTrace = new LogScreenTrace();
                break;

            case LogTraceType.File:
                newTrace = new LogFileTrace();
                break;

            case LogTraceType.Control:
                newTrace = new LogControlTrace();
                break;
            default:
                return false;
        }

        if (!newTrace.Init())
        {
            LogCenter.LogError("LogCenter::OpenTrace init error, type=" + type);
            return false;
        }

        // �����ǰ�У�Ҫ��֮ǰ���ͷŵ�
        if (m_CurTrace != null)
        {
            m_CurTrace.Release();
        }

        m_CurTrace = newTrace;
        return true;
    }

    /// <summary>
    /// �رյ�ǰTRACE
    /// </summary>
    public void Close()
    {
        if (m_CurTrace != null)
        {
            m_CurTrace.Release();
            m_CurTrace = null;
        }
    }
    public static void Log(string msg)
    {
        LogCenter.Instance().Push(LogType.Log, msg);
    }

    /// <summary>
    /// ����LOG��ʹ�������ӡLOGʱ�����Ƶ�ʵ��ã��п��ܻ�Ӱ��֡���½� 
    /// </summary>
    public static void LogWarning(string msg)
    {
        LogCenter.Instance().Push(LogType.Warning, msg);
    }

    /// <summary>
    /// ����LOG��ʹ�������ӡLOGʱ�����Ƶ�ʵ��ã��п��ܻ�Ӱ��֡���½�
    /// </summary>
    public static void LogError(string msg)
    {
        LogCenter.Instance().Push(LogType.Error, msg);
    }
}
