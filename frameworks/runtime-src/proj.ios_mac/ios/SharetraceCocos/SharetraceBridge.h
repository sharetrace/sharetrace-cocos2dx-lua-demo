//
//  SharetraceBridge.h
//  SharetraceLua
//
//  Created by Kenneth on 2021/8/24.
//

#import <Foundation/Foundation.h>
#import "Sharetrace.h"

@interface SharetraceBridge : NSObject<SharetraceDelegate>

@property (nonatomic, assign)BOOL hasInit;
@property (nonatomic, copy)NSString * _Nullable wakeUpTrace;
@property (nonatomic, assign)BOOL hasRegisterWakeup;
@property (nonatomic, assign)int funcId;

+(void)getInstallTrace:(NSDictionary *_Nullable)dict;

+(void)registerWakeUpTrace:(NSDictionary *_Nullable)dict;

+ (SharetraceBridge *_Nonnull)shared;

/**
 * SharetraceSDK 初始化
 */
+ (void)startInit;

/**
 * 处理 URI Schemes 逻辑
 * @param url 通过Schemes调起时，系统回调回来的URL
 * @return bool Sharetrace是否成功识别该URL
 */
+ (BOOL)handleSchemeLinkURL:(NSURL * _Nullable)url;

/**
 * 处理 Universal link 逻辑
 * @param userActivity 通过Universal link调起时，包含系统回调回来的URL信息的NSUserActivity
 * @return bool Sharetrace是否成功识别该URL
 */
+ (BOOL)handleUniversalLink:(NSUserActivity * _Nullable)userActivity;

@end

