/********************************************************************
	created:	2014/06/18
	author:		张呈鹏
	purpose:	服务器返回的结果码
*********************************************************************/

/************************************************************************/
/*           修改此文件必须同步修改DResultCode.cs						*/
/************************************************************************/

//#ifndef _DRESULTCODE_H_
//#define _DRESULTCODE_H_

public enum RESULT_CODE
{
    RESULT_COMMON_SUCCEED = 0,								// 操作成功
    RESULT_COMMON_FAILURE,										// 操作失败
    RESULT_COMMON_ERROR,										// 服务器内部错误

    /*MSG_LOGIN_REGISTER*/
    RESULT_REGISTER_USER_INVALID,								// 帐号不符合条件
    RESULT_REGISTER_USER_EXISTS,								// 帐号已经存在

    /*MSG_LOGIN_LOGINUSER*/
    RESULT_LOGIN_USER_INEXISTENT,								// 帐号不存在
    RESULT_LOGIN_PASSWORD_ERROR,								// 密码错误
    RESULT_LOGIN_RECONNECT_ERROR,								// 重连错误

    /*MSG_LOGIN_CREATEACTOR*/
    RESULT_CREATEACTOR_NAMEINVALID,								// 角色名不符合条件
    RESULT_CREATEACTOR_NAMEEXISTS,								// 角色名已经存在

    /*MSG_LOGIN_DELETEACTOR*/
    RESULT_DELETEACTOR_INEXISTENT,								// 角色不存在

    /*MSG_LOGIN_SELETEACTOR*/
    RESULT_SELECTACTOR_USERLOCKED,								// 帐号已被锁定
    RESULT_SELECTACTOR_EXISTS,									// 帐号已经在游戏中
    RESULT_SELECTACTOR_KICKOUT,									// 帐号其他地方登录

};