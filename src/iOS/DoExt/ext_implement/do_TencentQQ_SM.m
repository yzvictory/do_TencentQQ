//
//  do_TencentQQ_SM.m
//  DoExt_SM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_TencentQQ_SM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "doJsonNode.h"

#import <TencentOpenAPI/TencentOAuth.h>

@interface do_TencentQQ_SM() <TencentSessionDelegate>
@property(nonatomic,strong) TencentOAuth *tencent_oauth;
@property(nonatomic,copy) NSString *callbackName;
@property(nonatomic,strong) id<doIScriptEngine> scritEngine;

@end

@implementation do_TencentQQ_SM
#pragma mark -
#pragma mark - 同步异步方法的实现
/*
 1.参数节点
     doJsonNode *_dictParas = [parms objectAtIndex:0];
     a.在节点中，获取对应的参数
     NSString *title = [_dictParas GetOneText:@"title" :@"" ];
     说明：第一个参数为对象名，第二为默认值
 
 2.脚本运行时的引擎
     id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
 
 同步：
 3.同步回调对象(有回调需要添加如下代码)
     doInvokeResult *_invokeResult = [parms objectAtIndex:2];
     回调信息
     如：（回调一个字符串信息）
     [_invokeResult SetResultText:((doUIModule *)_model).UniqueKey];
 异步：
 3.获取回调函数名(异步方法都有回调)
     NSString *_callbackName = [parms objectAtIndex:2];
     在合适的地方进行下面的代码，完成回调
     新建一个回调对象
     doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
     填入对应的信息
     如：（回调一个字符串）
     [_invokeResult SetResultText: @"异步方法完成"];
     [_scritEngine Callback:_callbackName :_invokeResult];
 */
//同步
 - (void)logout:(NSArray *)parms
 {
//     doJsonNode *_dictParas = [parms objectAtIndex:0];
     self.scritEngine = [parms objectAtIndex:1];
     //自己的代码实现
     [_tencent_oauth logout:self];
 }
//异步
- (void)getUserInfo:(NSArray *)parms
{
//    doJsonNode *_dictParas = [parms objectAtIndex:0];
    self.scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    self.callbackName = [parms objectAtIndex:2];

    if ([_tencent_oauth getUserInfo]) {
        
    }
    else
    {
        
    }
//    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
}
- (void)login:(NSArray *)parms
{
    doJsonNode *_dictParas = [parms objectAtIndex:0];
    self.scritEngine  = [parms objectAtIndex:1];
    //自己的代码实现
    
    self.callbackName = [parms objectAtIndex:2];
//    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    
    NSString *app_id = [_dictParas GetOneText:@"appId" :@""];
    _tencent_oauth = [[TencentOAuth alloc]initWithAppId:app_id andDelegate:self];
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_ALBUM,
                            kOPEN_PERMISSION_ADD_IDOL,
                            kOPEN_PERMISSION_ADD_ONE_BLOG,
                            kOPEN_PERMISSION_ADD_PIC_T,
                            kOPEN_PERMISSION_ADD_SHARE,
                            kOPEN_PERMISSION_ADD_TOPIC,
                            kOPEN_PERMISSION_CHECK_PAGE_FANS,
                            kOPEN_PERMISSION_DEL_IDOL,
                            kOPEN_PERMISSION_DEL_T,
                            kOPEN_PERMISSION_GET_FANSLIST,
                            kOPEN_PERMISSION_GET_IDOLLIST,
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_OTHER_INFO,
                            kOPEN_PERMISSION_GET_REPOST_LIST,
                            kOPEN_PERMISSION_LIST_ALBUM,
                            kOPEN_PERMISSION_UPLOAD_PIC,
                            kOPEN_PERMISSION_GET_VIP_INFO,
                            kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                            kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                            kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                            nil];
    [_tencent_oauth authorize:permissions];
}

#pragma -mark -
#pragma -mark TencentSessionDelegate
/**
 *  登录时网络有问题的回调
 */
-(void)tencentDidNotNetWork
{
    
}
/**
 *  登录成功后的回调
 */
-(void)tencentDidLogin
{
    NSString *accessToken = [_tencent_oauth accessToken];
    NSString *openID = [_tencent_oauth openId];
    
    NSString *expirationDate = [NSString stringWithFormat:@"%f",[_tencent_oauth expirationDate].timeIntervalSinceNow];
    NSString *ret = [_tencent_oauth passData][@"ret"];
    NSString *pay_token = [_tencent_oauth passData][@"pay_token"];
    NSString *msg = [_tencent_oauth passData][@"msg"];
    NSString *resultStr = [NSString stringWithFormat:@"{ret:%@,pay_token:%@,openid:%@,expires_in:%@,msg:%@,access_token:%@}",ret,pay_token,openID,expirationDate,msg,accessToken];
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    [_invokeResult SetResultText:resultStr];
    NSLog(@"登陆返回信息：%@",resultStr);
    [self.scritEngine Callback:self.callbackName :_invokeResult];
}
/**
 *  登录失败后的回调
 *
 *  @param cancelled 代表用户是否主动退出登录
 */
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    
}
/**
 *  退出登录的回调
 */
-(void)tencentDidLogout
{
    NSLog(@"收到登出回调");
}
/**
 *
 * 获取用户个人信息回调
 *
 *  @param response
 */
-(void)getUserInfoResponse:(APIResponse *)response
{
    if (URLREQUEST_SUCCEED == response.retCode && kOpenSDKErrorSuccess == response.detailRetCode)
    {
        NSData *dictData = [NSJSONSerialization dataWithJSONObject:response.jsonResponse options:NSJSONWritingPrettyPrinted error:nil];
        NSString *resultStr = [[NSString alloc]initWithData:dictData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultStr);
        doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
        [_invokeResult SetResultText:resultStr];
        [self.scritEngine Callback:self.callbackName :_invokeResult];
    }
}
@end





















