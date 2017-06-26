using UnityEngine;
using System.Collections;
using System.IO;

public class CsvReader
{
    private string[][] Array;

    public void ReadFile(string file_path)
    {
        //读取csv文件  
        TextAsset binAsset = Resources.Load(file_path, typeof(TextAsset)) as TextAsset;
        SetData(binAsset.text);
    }

    public void SetData(string text)
    {
        //读取每一行的内容  
        string[] lineArray = text.Split('\r');

        //创建二维数组  
        Array = new string[lineArray.Length][];

        //把csv中的数据储存在二位数组中  
        for (int i = 0; i < lineArray.Length; i++)
        {
            lineArray[i] = lineArray[i].Trim('\n');
            Array[i] = lineArray[i].Split(',');
        }
    }

    public string GetDataByRowAndCol(int nRow, int nCol)
    {
        if (Array.Length <= 0 || nRow >= Array.Length)
            return "";
        if (nCol >= Array[0].Length)
            return "";

        return Array[nRow][nCol];
    }

    public int GetRow()
    {
        return Array.Length;
    }

    string GetDataByIdAndName(int nId, string strName)
    {
        if (Array.Length <= 0)
            return "";

        int nRow = Array.Length;
        int nCol = Array[0].Length;
        for (int i = 1; i < nRow; ++i)
        {
            string strId = string.Format("\n{0}", nId);
            if (Array[i][0] == strId)
            {
                for (int j = 0; j < nCol; ++j)
                {
                    if (Array[0][j] == strName)
                    {
                        return Array[i][j];
                    }
                }
            }
        }

        return "";
    }  
}
