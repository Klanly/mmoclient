using UnityEngine;

public class LoginCallBack : Base
{

    public string luaPath = "ConnectToLogin.lua";
    public void LoginCb(string token)
    {
        Debug.Log("token" + token);
        string className = System.IO.Path.GetFileNameWithoutExtension(luaPath);
        var luaTable = LuaManager.GetTable(className);
        if (luaTable == null)
        {
            LuaManager.DoFile(className);
            if (!string.IsNullOrEmpty(className))
            {
                luaTable = LuaManager.GetTable(className);
                if (luaTable == null)
                {
                    Util.LogError("Game", string.Format("没有找到{0}对应的lua表, 请确保文件名和lua表名一致", className));
                }
            }
        }
        LuaManager.CallFunction("ConnectToLogin.ConnectToLoginServer", token);
    }
}
