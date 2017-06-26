using System.Collections;
using System;
using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// 工具类
/// </summary>
public static class CoreTool
{
    #region Config配置
    /// <summary>
    /// 验证当前文件是否为配置文件
    /// </summary>
    /// <param name="filePath">文件路径</param>
    /// <returns></returns>
    public static bool IsConfig(string filePath)
    {
        return true;
    }
    #endregion

    #region Camera
    /// <summary>
    /// 将源摄像机状态克隆到目标相机
    /// </summary>
    /// <param name="src">源相机</param>
    /// <param name="dest">目标相机</param>
    public static void CloneCameraModes(Camera src, Camera dest)
    {
        if (dest == null)
            return;
        // set camera to clear the same way as current camera
        dest.clearFlags = src.clearFlags;
        dest.backgroundColor = src.backgroundColor;
        if (src.clearFlags == CameraClearFlags.Skybox)
        {
            Skybox sky = src.GetComponent(typeof(Skybox)) as Skybox;
            Skybox mysky = dest.GetComponent(typeof(Skybox)) as Skybox;
            if (!sky || !sky.material)
            {
                mysky.enabled = false;
            }
            else
            {
                mysky.enabled = true;
                mysky.material = sky.material;
            }
        }
        // update other values to match current camera.
        // even if we are supplying custom camera&projection matrices,
        // some of values are used elsewhere (e.g. skybox uses far plane)
        dest.depth = src.depth;
        dest.farClipPlane = src.farClipPlane;
        dest.nearClipPlane = src.nearClipPlane;
        dest.orthographic = src.orthographic;
        dest.fieldOfView = src.fieldOfView;
        dest.aspect = src.aspect;
        dest.orthographicSize = src.orthographicSize;
    }

    /// <summary>
    /// 计算反射矩阵
    /// </summary>
    /// <param name="reflectionMat">原始矩阵</param>
    /// <param name="plane">反射平面</param>
    /// <returns>反射矩阵</returns>
    public static Matrix4x4 CalculateReflectionMatrix(Matrix4x4 reflectionMat, Vector4 plane)
    {
        reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
        reflectionMat.m01 = (-2F * plane[0] * plane[1]);
        reflectionMat.m02 = (-2F * plane[0] * plane[2]);
        reflectionMat.m03 = (-2F * plane[3] * plane[0]);

        reflectionMat.m10 = (-2F * plane[1] * plane[0]);
        reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
        reflectionMat.m12 = (-2F * plane[1] * plane[2]);
        reflectionMat.m13 = (-2F * plane[3] * plane[1]);

        reflectionMat.m20 = (-2F * plane[2] * plane[0]);
        reflectionMat.m21 = (-2F * plane[2] * plane[1]);
        reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
        reflectionMat.m23 = (-2F * plane[3] * plane[2]);

        reflectionMat.m30 = 0F;
        reflectionMat.m31 = 0F;
        reflectionMat.m32 = 0F;
        reflectionMat.m33 = 1F;
        return reflectionMat;
    }

    /// <summary>
    /// 计算指定平面在摄像机中的空间位置
    /// </summary>
    /// <param name="cam">摄像机</param>
    /// <param name="pos">平面上的点</param>
    /// <param name="normal">平面法线</param>
    /// <param name="sideSign">1：平面正面，-1：平面反面</param>
    /// <param name="clipPlaneOffset">平面法线位置偏移量</param>
    /// <returns></returns>
    public static Vector4 CameraSpacePlane(Camera cam, Vector3 pos, Vector3 normal, float sideSign, float clipPlaneOffset)
    {
        Vector3 offsetPos = pos + normal * clipPlaneOffset;
        Matrix4x4 m = cam.worldToCameraMatrix;
        Vector3 cpos = m.MultiplyPoint(offsetPos);
        Vector3 cnormal = m.MultiplyVector(normal).normalized * sideSign;
        return new Vector4(cnormal.x, cnormal.y, cnormal.z, -Vector3.Dot(cpos, cnormal));
    }

    /// <summary>
    /// 由剪裁面计算投影倾斜矩阵
    /// </summary>
    /// <param name="projection">投影矩阵</param>
    /// <param name="clipPlane">剪裁面</param>
    /// <param name="sideSign">剪裁平面(-1:平面下面,1:平面上面)</param>
    public static Matrix4x4 CalculateObliqueMatrix(Matrix4x4 projection, Vector4 clipPlane, float sideSign)
    {
        Vector4 q = projection.inverse * new Vector4(
            sgn(clipPlane.x),
            sgn(clipPlane.y),
            1.0f,
            1.0f
        );
        Vector4 c = clipPlane * (2.0F / (Vector4.Dot(clipPlane, q)));
        // third row = clip plane - fourth row
        projection[2] = c.x + Mathf.Sign(sideSign) * projection[3];
        projection[6] = c.y + Mathf.Sign(sideSign) * projection[7];
        projection[10] = c.z + Mathf.Sign(sideSign) * projection[11];
        projection[14] = c.w + Mathf.Sign(sideSign) * projection[15];
        return projection;
    }

    private static float sgn(float a)
    {
        if (a > 0.0f) return 1.0f;
        if (a < 0.0f) return -1.0f;
        return 0.0f;
    }

    /// <summary>
    /// 由水平、垂直距离修改倾斜矩阵
    /// </summary>
    /// <param name="projMatrix">倾斜矩阵</param>
    /// <param name="horizObl">水平方向</param>
    /// <param name="vertObl">垂直方向</param>
    /// <returns>修改后的倾斜矩阵</returns>
    public static Matrix4x4 CalculateObliqueMatrix(Matrix4x4 projMatrix, float horizObl, float vertObl)
    {
        Matrix4x4 mat = projMatrix;
        mat[0, 2] = horizObl;
        mat[1, 2] = vertObl;
        return mat;
    }
    #endregion

    #region Shader Matrix4x4
    /// <summary>
    /// tex2DProj到tex2D的uv纹理转换矩阵
    /// 在shader中,
    /// vert=>o.posProj = mul(_ProjMatrix, v.vertex);
    /// frag=>tex2D(_RefractionTex,float2(i.posProj) / i.posProj.w)
    /// </summary>
    /// <param name="transform">要显示纹理的对象</param>
    /// <param name="cam">当前观察的摄像机</param>
    /// <returns>返回转换矩阵</returns>
    public static Matrix4x4 UV_Tex2DProj2Tex2D(Transform transform, Camera cam)
    {
        Matrix4x4 scaleOffset = Matrix4x4.TRS(
            new Vector3(0.5f, 0.5f, 0.5f), Quaternion.identity, new Vector3(0.5f, 0.5f, 0.5f));
        Vector3 scale = transform.lossyScale;
        Matrix4x4 _ProjMatrix = transform.localToWorldMatrix * Matrix4x4.Scale(new Vector3(1.0f / scale.x, 1.0f / scale.y, 1.0f / scale.z));
        _ProjMatrix = scaleOffset * cam.projectionMatrix * cam.worldToCameraMatrix * _ProjMatrix;
        return _ProjMatrix;
    }
    #endregion

}

public static class ShadowUtils
{
    private static List<Vector4> _vList = new List<Vector4>();

    /// <summary>
    /// 根据主相机，设置光照相机
    /// </summary>
    /// <param name="mainCamera"></param>
    /// <param name="lightCamera"></param>
    public static void SetLightCamera(Camera mainCamera, Camera lightCamera)
    {
        //1、	求视锥8顶点 （主相机空间中） n平面（aspect * y, tan(r/2)* n,n）  f平面（aspect*y, tan(r/2) * f, f）
        float r = (mainCamera.fieldOfView / 180f) * Mathf.PI;
        //n平面
        Vector4 nLeftUp = new Vector4(-mainCamera.aspect * Mathf.Tan(r / 2) * mainCamera.nearClipPlane, Mathf.Tan(r / 2) * mainCamera.nearClipPlane, mainCamera.nearClipPlane, 1);
        Vector4 nRightUp = new Vector4(mainCamera.aspect * Mathf.Tan(r / 2) * mainCamera.nearClipPlane, Mathf.Tan(r / 2) * mainCamera.nearClipPlane, mainCamera.nearClipPlane, 1);
        Vector4 nLeftDonw = new Vector4(-mainCamera.aspect * Mathf.Tan(r / 2) * mainCamera.nearClipPlane, -Mathf.Tan(r / 2) * mainCamera.nearClipPlane, mainCamera.nearClipPlane, 1);
        Vector4 nRightDonw = new Vector4(mainCamera.aspect * Mathf.Tan(r / 2) * mainCamera.nearClipPlane, -Mathf.Tan(r / 2) * mainCamera.nearClipPlane, mainCamera.nearClipPlane, 1);

        //f平面
        Vector4 fLeftUp = new Vector4(-mainCamera.aspect * Mathf.Tan(r / 2) * mainCamera.farClipPlane, Mathf.Tan(r / 2) * mainCamera.farClipPlane, mainCamera.farClipPlane, 1);
        Vector4 fRightUp = new Vector4(mainCamera.aspect * Mathf.Tan(r / 2) * mainCamera.farClipPlane, Mathf.Tan(r / 2) * mainCamera.farClipPlane, mainCamera.farClipPlane, 1);
        Vector4 fLeftDonw = new Vector4(-mainCamera.aspect * Mathf.Tan(r / 2) * mainCamera.farClipPlane, -Mathf.Tan(r / 2) * mainCamera.farClipPlane, mainCamera.farClipPlane, 1);
        Vector4 fRightDonw = new Vector4(mainCamera.aspect * Mathf.Tan(r / 2) * mainCamera.farClipPlane, -Mathf.Tan(r / 2) * mainCamera.farClipPlane, mainCamera.farClipPlane, 1);

        //2、将8个顶点变换到世界空间

        Matrix4x4 mainv2w = mainCamera.transform.localToWorldMatrix;//本来这里的矩阵使用mainCamera.cameraToWorldMatrix,但是请看：http://docs.unity3d.com/ScriptReference/Camera-cameraToWorldMatrix.html   cameraToWorldMatrix返回的是GL风格的camera空间的矩阵，z是负的，跟untiy编辑器中的不对应，（也是坑爹的很，就不能统一吗），所以我们直接使用localToWorldMatrix
        Vector4 wnLeftUp = mainv2w * nLeftUp;
        Vector4 wnRightUp = mainv2w * nRightUp;
        Vector4 wnLeftDonw = mainv2w * nLeftDonw;
        Vector4 wnRightDonw = mainv2w * nRightDonw;
        //
        Vector4 wfLeftUp = mainv2w * fLeftUp;
        Vector4 wfRightUp = mainv2w * fRightUp;
        Vector4 wfLeftDonw = mainv2w * fLeftDonw;
        Vector4 wfRightDonw = mainv2w * fRightDonw;

        //将灯光相机设置在mainCamera视锥中心
        Vector4 nCenter = (wnLeftUp + wnRightUp + wnLeftDonw + wnRightDonw) / 4f;
        Vector4 fCenter = (wfLeftUp + wfRightUp + wfLeftDonw + wfRightDonw) / 4f;

        lightCamera.transform.position = (nCenter + fCenter) / 2f;
        //3、	求光view矩阵
        Matrix4x4 lgihtw2v = lightCamera.transform.worldToLocalMatrix;//本来这里使用lightCamera.worldToCameraMatrix,但是同上面不使用mainCamera.cameraToWorldMatrix的原因一样，我们直接使用worldToLocalMatrix
                                                                      //4、	把顶点从世界空间变换到光view空间
        Vector4 vnLeftUp = lgihtw2v * wnLeftUp;
        Vector4 vnRightUp = lgihtw2v * wnRightUp;
        Vector4 vnLeftDonw = lgihtw2v * wnLeftDonw;
        Vector4 vnRightDonw = lgihtw2v * wnLeftDonw;
        //
        Vector4 vfLeftUp = lgihtw2v * wfLeftUp;
        Vector4 vfRightUp = lgihtw2v * wfRightUp;
        Vector4 vfLeftDonw = lgihtw2v * wfLeftDonw;
        Vector4 vfRightDonw = lgihtw2v * wfRightDonw;

        _vList.Clear();
        _vList.Add(vnLeftUp);
        _vList.Add(vnRightUp);
        _vList.Add(vnLeftDonw);
        _vList.Add(vnRightDonw);

        _vList.Add(vfLeftUp);
        _vList.Add(vfRightUp);
        _vList.Add(vfLeftDonw);
        _vList.Add(vfRightDonw);
        //5、	求包围盒 (由于光锥xy轴的对称性，这里求最大包围盒就好，不是严格意义的AABB)
        float maxX = -float.MaxValue;
        float maxY = -float.MaxValue;
        float maxZ = -float.MaxValue;
        float minZ = float.MaxValue;
        for (int i = 0; i < _vList.Count; i++)
        {
            Vector4 v = _vList[i];
            if (Mathf.Abs(v.x) > maxX)
            {
                maxX = Mathf.Abs(v.x);
            }
            if (Mathf.Abs(v.y) > maxY)
            {
                maxY = Mathf.Abs(v.y);
            }
            if (v.z > maxZ)
            {
                maxZ = v.z;
            }
            else if (v.z < minZ)
            {
                minZ = v.z;
            }
        }
        //5.5 优化，如果8个顶点在光锥view空间中的z<0,那么如果n=0，就可能出现应该被渲染depthmap的物体被光锥近裁面剪裁掉的情况，所以z < 0 的情况下要延光照负方向移动光源位置以避免这种情况
        if (minZ < 0)
        {
            lightCamera.transform.position += -lightCamera.transform.forward.normalized * Mathf.Abs(minZ);
            maxZ = maxZ - minZ;
        }

        //6、	根据包围盒确定投影矩阵 包围盒的最大z就是f，Camera.orthographicSize由y max决定 ，还要设置Camera.aspect
        lightCamera.orthographic = true;
        lightCamera.aspect = maxX / maxY;
        lightCamera.orthographicSize = maxY;
        lightCamera.nearClipPlane = 0.0f;
        lightCamera.farClipPlane = Mathf.Abs(maxZ);
    }
    /// <summary>
    /// 根据场景包围盒来设置光锥
    /// </summary>
    /// <param name="b"></param>
    /// <param name="lightCamera"></param>
    public static void SetLightCamera(Bounds b, Camera lightCamera)
    {
        //1、将lightCamera放在包围盒中心
        lightCamera.transform.position = b.center;
        //2、	求光view矩阵
        Matrix4x4 lgihtw2v = lightCamera.transform.worldToLocalMatrix;//本来这里使用lightCamera.worldToCameraMatrix,但是同上面不使用mainCamera.cameraToWorldMatrix的原因一样，我们直接使用worldToLocalMatrix
                                                                      //3、	把顶点从世界空间变换到光view空间
        Vector4 vnLeftUp = lgihtw2v * new Vector3(b.max.x, b.max.y, b.max.z);
        Vector4 vnRightUp = lgihtw2v * new Vector3(b.max.x, b.min.y, b.max.z);
        Vector4 vnLeftDonw = lgihtw2v * new Vector3(b.max.x, b.max.y, b.min.z);
        Vector4 vnRightDonw = lgihtw2v * new Vector3(b.min.x, b.max.y, b.max.z);
        //
        Vector4 vfLeftUp = lgihtw2v * new Vector3(b.min.x, b.min.y, b.min.z); ;
        Vector4 vfRightUp = lgihtw2v * new Vector3(b.min.x, b.max.y, b.min.z); ;
        Vector4 vfLeftDonw = lgihtw2v * new Vector3(b.min.x, b.min.y, b.max.z); ;
        Vector4 vfRightDonw = lgihtw2v * new Vector3(b.max.x, b.min.y, b.min.z); ;

        _vList.Clear();
        _vList.Add(vnLeftUp);
        _vList.Add(vnRightUp);
        _vList.Add(vnLeftDonw);
        _vList.Add(vnRightDonw);

        _vList.Add(vfLeftUp);
        _vList.Add(vfRightUp);
        _vList.Add(vfLeftDonw);
        _vList.Add(vfRightDonw);
        //4、	求包围盒 (由于光锥xy轴的对称性，这里求最大包围盒就好，不是严格意义的AABB)
        float maxX = -float.MaxValue;
        float maxY = -float.MaxValue;
        float maxZ = -float.MaxValue;
        float minZ = float.MaxValue;
        for (int i = 0; i < _vList.Count; i++)
        {
            Vector4 v = _vList[i];
            if (Mathf.Abs(v.x) > maxX)
            {
                maxX = Mathf.Abs(v.x);
            }
            if (Mathf.Abs(v.y) > maxY)
            {
                maxY = Mathf.Abs(v.y);
            }
            if (v.z > maxZ)
            {
                maxZ = v.z;
            }
            else if (v.z < minZ)
            {
                minZ = v.z;
            }
        }
        //4.5 优化，如果8个顶点在光锥view空间中的z<0,那么如果n=0，就可能出现应该被渲染depthmap的物体被光锥近裁面剪裁掉的情况，所以z < 0 的情况下要延光照负方向移动光源位置以避免这种情况
        if (minZ < 0)
        {
            lightCamera.transform.position += -lightCamera.transform.forward.normalized * Mathf.Abs(minZ);
            maxZ = maxZ - minZ;
        }

        //5、	根据包围盒确定投影矩阵 包围盒的最大z就是f，Camera.orthographicSize由y max决定 ，还要设置Camera.aspect
        lightCamera.orthographic = true;
        lightCamera.aspect = maxX / maxY;
        lightCamera.orthographicSize = maxY;
        lightCamera.nearClipPlane = 0.0f;
        lightCamera.farClipPlane = Mathf.Abs(maxZ);
    }

}
