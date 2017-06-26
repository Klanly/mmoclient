/********************************************************************************
** auth： yanwei
** date： 2017-2-20
** desc： 性能评测显示 。
*********************************************************************************/

using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TMPro;
using System.Text;
using System;

public class AdvancedPerf : MonoBehaviour {

    private const int warningLevelValue = 50;
    private const int criticalLevelValue = 20;
    public const int MEMORY_DIVIDER = 1048576; // 1024^2

    private const string TEXT_START = "<color=#{0}>";
    private const string LINE_START_TOTAL = "MEM: ";
    private const string LINE_START_ALLOCATED = "MEM ALLOC: ";
    private const string LINE_START_MONO = "MEM MONO: ";
    private const string LINE_END = " MB";
    private const string TEXT_END = "</color>";
    private const string COROUTINE_NAME = "UpdateFPSCounter";
    private const string FPS_TEXT_START = "<color=#{0}>FPS: ";
    private const string FPS_TEXT_END = "</color>";
    private const string MS_TEXT_START = " <color=#{0}>[";
    private const string MS_TEXT_END = " MS]</color>";
    private const string MIN_TEXT_START = "<color=#{0}>MIN: ";
    private const string MIN_TEXT_END = "</color> ";
    private const string MAX_TEXT_START = "<color=#{0}>MAX: ";
    private const string MAX_TEXT_END = "</color>";
    private const string AVG_TEXT_START = "<color=#{0}>AVG: ";
    private const string AVG_TEXT_END = "</color>";
    internal const char NEW_LINE = '\n';
    internal const char SPACE = ' ';
    private int LastMinimumValue,LastMaximumValue;
    private int LastValue, currentAverageSamples, minMaxIntervalsSkipped;
    internal float newValue;
    GameObject canvasObject;
    private Canvas canvas;
    private float updateInterval = 0.5f;

    private float scaleFactor = 1;
    private int sortingOrder = 10000;
    private GameObject uiTextObject;
    private TextMeshProUGUI uiText;
    private StringBuilder text;

    private Color color = new Color32(200, 200, 200, 255);
    private Color colorWarning = new Color32(236, 224, 88, 255);
    private Color colorGPu = new Color32(120, 120,120, 255);
    private Color colorCritical = new Color32(249, 91, 91, 255);
    private float LastMillisecondsValue, LastAverageMillisecondsValue, LastMaxMillisecondsValue;
    private float LastAverageValue, currentAverageRaw, LastMinMillisecondsValue;
    private int averageSamples = 50;
    private float[] accumulatedAverageSamples;
    private int minMaxIntervalsToSkip = 3;
    private uint LastTotalValue, LastAllocatedValue;
    private long LastMonoValue;
    private bool bShow = false;

    // ----------------------------------------------------------------------------
    // Color fields
    // ----------------------------------------------------------------------------
    private string colorCached;
    private string colorCachedMs;
    private string colorCachedMin;
    private string colorCachedMax;
    private string colorCachedAvg;

    private string colorWarningCached;
    private string colorWarningCachedMs;
    private string colorWarningCachedMin;
    private string colorWarningCachedMax;
    private string colorWarningCachedAvg;

    private string colorCriticalCached;
    private string colorCriticalCachedMs;
    private string colorCriticalCachedMin;
    private string colorCriticalCachedMax;
    private string colorCriticalCachedAvg;
    
    private void Start()
    {
       // ConfigureCanvas();
       // StartCoroutine(COROUTINE_NAME);
        SceneManager.sceneLoaded += OnLevelWasLoadedNew;
        color = new Color32(85, 218, 102, 255);
        text = new StringBuilder(500);
        if (colorCached == null)
        {
            CacheCurrentColor();
        }

        if (colorWarningCached == null)
        {
            CacheWarningColor();
        }

        if (colorCriticalCached == null)
        {
            CacheCriticalColor();
        }
    }

    private void OnLevelWasLoadedNew(Scene scene, LoadSceneMode mode)
	{
        if (!Application.isPlaying) return;
        LastMinimumValue = -1;
        LastMaximumValue = -1;
	}


    private IEnumerator UpdateFPSCounter()
    {
        while (true)
        {
            float previousUpdateTime = Time.unscaledTime;
            int previousUpdateFrames = Time.frameCount;
            yield return new WaitForSeconds(updateInterval);
            float timeElapsed = Time.unscaledTime - previousUpdateTime;
            int framesChanged = Time.frameCount - previousUpdateFrames;

            newValue = framesChanged / timeElapsed;
            UpdateValue();
        }
    }

    public void SwitchAdvancedPerf()
    {
        bShow = !bShow;
        if (bShow && canvasObject == null)
        {
            ConfigureCanvas();
            StartCoroutine(COROUTINE_NAME);
        }
        else
        {
            Destroy(canvasObject);
            canvasObject = null;
            StopCoroutine(COROUTINE_NAME);
        }

    }

    internal static void ResetRectTransform(RectTransform rectTransform)
    {
        rectTransform.localRotation = Quaternion.identity;
        rectTransform.localScale = Vector3.one;
        rectTransform.pivot = new Vector2(0.5f, 0.5f);
        rectTransform.anchorMin = Vector2.zero;
        rectTransform.anchorMax = Vector2.one;
        rectTransform.anchoredPosition3D = Vector3.zero;
        rectTransform.offsetMin = Vector2.zero;
        rectTransform.offsetMax = Vector2.zero;
    }

    private void ConfigureCanvas()
    {
        canvasObject = new GameObject("CountersCanvas");
        canvasObject.tag = gameObject.tag;
        canvasObject.layer = gameObject.layer;
        canvasObject.transform.parent = transform;

        canvas = canvasObject.AddComponent<Canvas>();

        RectTransform canvasRectTransform = canvasObject.GetComponent<RectTransform>();

        ResetRectTransform(canvasRectTransform);
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.pixelPerfect = true;
        canvas.sortingOrder = sortingOrder;

        CanvasScaler canvasScaler = canvasObject.AddComponent<CanvasScaler>();
        canvasScaler.scaleFactor = scaleFactor;
        uiTextObject = new GameObject("FpsCounter");
        uiTextObject.transform.SetParent(canvasObject.transform, false);
        uiText = uiTextObject.AddComponent<TextMeshProUGUI>();
        uiText.alignment = TextAlignmentOptions.TopRight;
        uiText.rectTransform.localRotation = Quaternion.identity;
        uiText.rectTransform.sizeDelta = new Vector2(270f, 0f); ;
        uiText.rectTransform.anchoredPosition3D = new Vector2(-250f,-5f);
        uiText.rectTransform.anchorMin = Vector2.one;
        uiText.rectTransform.anchorMax = Vector2.one;
        uiText.fontSize = 20f;
        uiText.font= ObjectPoolManager.GetSharedResource("FontsMaterials/ARIAL SDF", EResType.eResFontAsset) as TMP_FontAsset;
       // uiText.fontMaterial = ObjectPoolManager.GetSharedResource("Fonts/SIMLI SDF - Outline", EResType.eResMaterial) as Material;
        bShow = true;
    }

    protected void CacheCurrentColor()
    {
        string colorString = Color32ToHex(color);
        colorCached = string.Format(FPS_TEXT_START, colorString);
        colorCachedMs = string.Format(MS_TEXT_START, colorString);
        colorCachedMin = string.Format(MIN_TEXT_START, colorString);
        colorCachedMax = string.Format(MAX_TEXT_START, colorString);
        colorCachedAvg = string.Format(AVG_TEXT_START, colorString);
    }

    protected void CacheWarningColor()
    {
        string colorString = Color32ToHex(colorWarning);
        colorWarningCached = string.Format(FPS_TEXT_START, colorString);
        colorWarningCachedMs = string.Format(MS_TEXT_START, colorString);
        colorWarningCachedMin = string.Format(MIN_TEXT_START, colorString);
        colorWarningCachedMax = string.Format(MAX_TEXT_START, colorString);
        colorWarningCachedAvg = string.Format(AVG_TEXT_START, colorString);
    }

    protected void CacheCriticalColor()
    {
        string colorString = Color32ToHex(colorCritical);
        colorCriticalCached = string.Format(FPS_TEXT_START, colorString);
        colorCriticalCachedMs = string.Format(MS_TEXT_START, colorString);
        colorCriticalCachedMin = string.Format(MIN_TEXT_START, colorString);
        colorCriticalCachedMax = string.Format(MAX_TEXT_START, colorString);
        colorCriticalCachedAvg = string.Format(AVG_TEXT_START, colorString);
    }

    internal static string Color32ToHex(Color32 color)
    {
        return color.r.ToString("x2") + color.g.ToString("x2") + color.b.ToString("x2") + color.a.ToString("x2");
    }

    internal void UpdateValue()
    {
        if (canvasObject == null) return;
        int roundedValue = (int)newValue;
        if (LastValue != roundedValue)
        {
            LastValue = roundedValue;
        }

        string coloredStartText;
        if (LastValue >= warningLevelValue)
            coloredStartText = colorCached;
        else if (LastValue <= criticalLevelValue)
            coloredStartText = colorCriticalCached;
        else
            coloredStartText = colorWarningCached;
        LastMillisecondsValue = 1000f / newValue;
     
        
        text.Length = 0;
        
        text.Append(coloredStartText).Append(LastValue).Append(FPS_TEXT_END);
        if (LastValue >= warningLevelValue)
            coloredStartText = colorCachedMs;
        else if (LastValue <= criticalLevelValue)
            coloredStartText = colorCriticalCachedMs;
        else
            coloredStartText = colorWarningCachedMs;



        text.Append(coloredStartText).Append(LastMillisecondsValue.ToString("F")).Append(MS_TEXT_END);
        /* text.Append( NEW_LINE);

         int currentAverageRounded = AverageSeconds();
         if (currentAverageRounded >= warningLevelValue)
             coloredStartText = colorCachedAvg;
         else if (currentAverageRounded <= criticalLevelValue)
             coloredStartText = colorCriticalCachedAvg;
         else
             coloredStartText = colorWarningCachedAvg;

         text.Append(coloredStartText).Append(currentAverageRounded);

         text.Append(" [").Append(LastAverageMillisecondsValue.ToString("F")).Append(" MS]");

         text.Append(AVG_TEXT_END);
          GPuDeviceInfo();*/
        MemoryCounter();
        //text.Append(NEW_LINE);        
        //long delay = stm.delayTime;
        //text.Append("<size=20>ping interval:" + (stm.pingInterval) + "</size>");
        //text.Append(NEW_LINE);
        //long delta = stm.deltaTime;
        //text.Append("<size=20>delta time:" + delta + "</size>");
        //text.Append(NEW_LINE);
        //text.Append("<size=20>delay:</size>");
        //if (delay < 80)
        //{
        //    text.Append("<color=green><size=20>" + delay + "</size></color>");
        //}
        //else if(delay < 120)
        //{
        //    text.Append("<color=yellow><size=20>" + delay + "</size></color>");
        //}
        //else
        //{
        //    text.Append("<color=red><size=20>" + delay + "</size></color>");
        //}
        



        uiText.text = text.ToString();
    }

    private float GetAverageFromAccumulatedSamples()
    {
        float averageFps;
        float totalFps = 0;

        for (int i = 0; i < averageSamples; i++)
        {
            totalFps += accumulatedAverageSamples[i];
        }

        if (currentAverageSamples < averageSamples)
        {
            averageFps = totalFps / currentAverageSamples;
        }
        else
        {
            averageFps = totalFps / averageSamples;
        }

        return averageFps;
    }

    public void ResetAverage()
    {
        if (!Application.isPlaying) return;

        LastAverageValue = 0;
        currentAverageSamples = 0;
        currentAverageRaw = 0;

        if (averageSamples > 0 && accumulatedAverageSamples != null)
        {
            System.Array.Clear(accumulatedAverageSamples, 0, accumulatedAverageSamples.Length);
        }
    }

    void MinMaxValue()
    {
        if (minMaxIntervalsSkipped < minMaxIntervalsToSkip)
        {
            minMaxIntervalsSkipped++;
        }
        else  
        {
            if (LastMinimumValue == -1)
            {
                LastMinimumValue = LastValue;
                LastMinMillisecondsValue = 1000f / LastMinimumValue;
            }
            else if (LastValue < LastMinimumValue)
            {
                LastMinimumValue = LastValue;
                LastMinMillisecondsValue = 1000f / LastMinimumValue;
            }

            if (LastMaximumValue == -1)
            {
                LastMaximumValue = LastValue;
                LastMaxMillisecondsValue = 1000f / LastMaximumValue;
            }
            else if (LastValue > LastMaximumValue)
            {
                LastMaximumValue = LastValue;
                LastMaxMillisecondsValue = 1000f / LastMaximumValue;
            }
        }
    }

    int AverageSeconds()
    {
        int currentAverageRounded = 0;
        if (averageSamples == 0)
        {
            currentAverageSamples++;
            currentAverageRaw += (LastValue - currentAverageRaw) / currentAverageSamples;
        }
        else
        {
            if (accumulatedAverageSamples == null)
            {
                accumulatedAverageSamples = new float[averageSamples];
                ResetAverage();
            }

            accumulatedAverageSamples[currentAverageSamples % averageSamples] = LastValue;
            currentAverageSamples++;

            currentAverageRaw = GetAverageFromAccumulatedSamples();
        }

        currentAverageRounded = Mathf.RoundToInt(currentAverageRaw);

        if (LastAverageValue != currentAverageRounded )
        {
            LastAverageValue = currentAverageRounded;

            LastAverageMillisecondsValue = 1000f / LastAverageValue;
        }
        return currentAverageRounded;
    }

    void MemoryCounter()
    {

        string colorMem = string.Format(TEXT_START, Color32ToHex(colorWarning));
        text.Append(NEW_LINE);
        text.Append(colorMem);
        uint value = Profiler.GetTotalReservedMemory();

        bool newValue;
        newValue = (LastTotalValue != value);

        if (newValue )
        {
            LastTotalValue =  value ;
         }

         value = Profiler.GetTotalAllocatedMemory();

        newValue = (LastAllocatedValue != value);

        if (newValue)
        {
            LastAllocatedValue = value ;
        }

        long monoMemory = GC.GetTotalMemory(false);

        newValue = (LastMonoValue != monoMemory);

        if (newValue )
        {
            LastMonoValue =monoMemory ;
        }
        text.Append(LINE_START_TOTAL);

        text.Append((LastTotalValue / (float)MEMORY_DIVIDER).ToString("F"));
        text.Append(LINE_END);
       /* bool needNewLine = true;
        if (needNewLine) text.Append(NEW_LINE);
        text.Append(LINE_START_ALLOCATED);

        text.Append((LastAllocatedValue / (float)MEMORY_DIVIDER).ToString("F"));
        text.Append(LINE_END);
        needNewLine = true;

        if (needNewLine) text.Append(NEW_LINE);
        text.Append(LINE_START_MONO);
        text.Append((LastMonoValue / (float)MEMORY_DIVIDER).ToString("F"));

        text.Append(LINE_END);*/
        text.Append(TEXT_END);
    }

    void GPuDeviceInfo()
    {
        string colorgpu = string.Format(TEXT_START, Color32ToHex(colorGPu));
        text.Append(NEW_LINE);
        text.Append(colorgpu);
        text.Append("GPU: ").Append(SystemInfo.graphicsDeviceVersion);
    	text.Append(" [").Append(SystemInfo.graphicsDeviceType).Append("]");

        text.Append(NEW_LINE);

        text.Append("GPU: SM: ");
        int sm = SystemInfo.graphicsShaderLevel;
        if (sm >= 10 && sm <= 99)
        {
            text.Append(sm /= 10).Append('.').Append(sm /= 10);
        }
        else
        {
            text.Append("N/A");
        }

        text.Append(", VRAM: ");
        int vram = SystemInfo.graphicsMemorySize;
        if (vram > 0)
        {
            text.Append(vram).Append(" MB");
        }
        else
        {
            text.Append("N/A");
        }
    }

    void OnDestroy()
    {
        StopCoroutine(COROUTINE_NAME);
    }



}
