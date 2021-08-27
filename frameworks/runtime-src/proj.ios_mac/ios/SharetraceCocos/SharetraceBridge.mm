//
//  SharetraceBridge.m
//  SharetraceLua
//
//  Created by Kenneth on 2021/8/24.
//

#import "SharetraceBridge.h"
#import "cocos2d.h"
USING_NS_CC;
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
#include "scripting/lua-bindings/manual/platform/ios/CCLuaObjcBridge.h"
#endif

@implementation SharetraceBridge

static NSString * const key_code = @"code";
static NSString * const key_msg = @"msg";
static NSString * const key_paramsData = @"paramsData";
static NSString * const key_channel = @"channel";

+(void)getInstallTrace:(NSDictionary *)dict {
    if (dict == nil) {
        return;
    }
    if ([dict objectForKey:@"funcId"] == nil) {
        return;
    }
    int funcId = [[dict objectForKey:@"funcId"] intValue];
    
    int defaultTimeout = 10;
    if ([dict objectForKey:@"seconds"] != nil) {
        int seconds = [[dict objectForKey:@"seconds"] intValue];
        if (seconds > 0) {
            defaultTimeout = seconds;
        }
    }
    
    int timeoutInMs = defaultTimeout * 1000;
    [Sharetrace getInstallTraceWithTimeout:timeoutInMs success:^(AppData * _Nullable appData) {
        if (appData == nil) {
            NSString* ret = [SharetraceBridge parseToResultDict:-1 :@"Extract data fail." :@"" :@""];
            NSLog(@"Sharetrace ret 1: %@", ret);
            [SharetraceBridge onInstallResult:funcId :ret];
            return;
        }

        NSString* ret = [SharetraceBridge parseToResultDict:200 :@"Success" :appData.paramsData :appData.channel];
        NSLog(@"Sharetrace ret 2: %@", ret);
        [SharetraceBridge onInstallResult:funcId :ret];
    } fail:^(NSInteger code, NSString * _Nonnull message) {
        NSString* ret = [SharetraceBridge parseToResultDict:code :message :@"" :@""];
        NSLog(@"Sharetrace ret 3: %@", ret);
        [SharetraceBridge onInstallResult:funcId :ret];
    }];
}

+(void)onInstallResult:(int)funcId :(NSString*)result {
    LuaObjcBridge::pushLuaFunctionById(funcId);
    LuaObjcBridge::getStack()->pushString([result UTF8String]);
    LuaObjcBridge::getStack()->executeFunction(1);
    LuaObjcBridge::releaseLuaFunctionById(funcId);
}

+(void)registerWakeUpTrace:(NSDictionary *)dict {
    if (dict == nil) {
        return;
    }
    if ([dict objectForKey:@"funcId"] == nil) {
        return;
    }
    
    int funcId = [[dict objectForKey:@"funcId"] intValue];
    SharetraceBridge * sharedInstance = [SharetraceBridge shared];
    sharedInstance.funcId = funcId;
    sharedInstance.hasRegisterWakeup = YES;
    NSString* cacheWakeupTrace = sharedInstance.wakeUpTrace;
    if (cacheWakeupTrace != nil && cacheWakeupTrace.length > 0) {
        LuaObjcBridge::pushLuaFunctionById(funcId);
        LuaObjcBridge::getStack()->pushString([cacheWakeupTrace UTF8String]);
        LuaObjcBridge::getStack()->executeFunction(1);
    }
}

static SharetraceBridge * sharedInstance = nil;
+ (SharetraceBridge *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SharetraceBridge alloc] init];
    });
    return sharedInstance;
}

/**
 * SharetraceSDK 初始化
 */
+ (void)startInit {
    SharetraceBridge * sharedInstance = [SharetraceBridge shared];
    [Sharetrace initWithDelegate:sharedInstance];
    sharedInstance.hasInit = YES;
}

+ (BOOL)handleSchemeLinkURL:(NSURL * _Nullable)url {
    return [Sharetrace handleSchemeLinkURL:url];
}

+ (BOOL)handleUniversalLink:(NSUserActivity * _Nullable)userActivity {
    return [Sharetrace handleUniversalLink:userActivity];
}

- (void)getWakeUpTrace:(AppData *)appData {
    if (appData == nil) {
        return;
    }
    
    NSString* ret = [SharetraceBridge parseToResultDict:200 :@"Success" :appData.paramsData :appData.channel];
    
    SharetraceBridge * sharedInstance = [SharetraceBridge shared];
    if (sharedInstance.hasRegisterWakeup) {
        SharetraceBridge * sharedInstance = [SharetraceBridge shared];
        LuaObjcBridge::pushLuaFunctionById(sharedInstance.funcId);
        LuaObjcBridge::getStack()->pushString([ret UTF8String]);
        LuaObjcBridge::getStack()->executeFunction(1);
        sharedInstance.wakeUpTrace = nil;
    } else {
        sharedInstance.wakeUpTrace = ret;
    }
    
}

+ (NSString*)parseToResultDict:(NSInteger)code :(NSString*)msg :(NSString*)paramsData :(NSString*)channel {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict[key_code] = [NSNumber numberWithInteger:code];
    dict[key_msg] = msg;
    dict[key_paramsData] = paramsData;
    dict[key_channel] = channel;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    if (jsonData != nil) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    } else {
        return @"";
    }
}

@end
