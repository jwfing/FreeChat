//
//  AppDelegate.m
//  FreeChat
//
//  Created by Feng Junwen on 2/3/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "AVOSCloud/AVOSCloud.h"
#import "ConversationStore.h"
#import <AVOSCloudCrashReporting/AVOSCloudCrashReporting.h>
#import <AVOSCloudSNS/AVOSCloudSNS.h>

#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

// 注意：如果您使用了 LeanCloud 美国节点，请保持这一行；
//      如果您使用 LeanCloud 国内节点，请注释掉这一行。
//#define USE_US_CLUSTER 1

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [AVOSCloudCrashReporting enable];
#ifdef USE_US_CLUSTER
    [AVOSCloud useAVCloudUS];
    [AVOSCloud setApplicationId:@"l8j5lm8c9f9d2l90213i00wsdhhljbrwrn6g0apptblu7l90"
                      clientKey:@"b3uyj9cmk84s5t9n6z1rqs9pvf2azofgacy9bfigmiehhheg"];
    NSLog(@"use us cluster");
#else
    [AVOSCloud setApplicationId:@"xqbqp3jr39p1mfptkswia72icqkk6i2ic3vi4q1tbpu7ce8b"
                      clientKey:@"cfs0hpk9ai3f8kiwua7atnri8hrleodvipjy0dofj70ebbno"];
    NSLog(@"use cn cluster");
#endif

    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"2548122881" andAppSecret:@"ba37a6eb3018590b0d75da733c4998f8" andRedirectURI:@"http://wanpaiapp.com/oauth/callback/sina"];
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSQQ withAppKey:@"1104579343" andAppSecret:@"jKE8IigA9zgMgg4m" andRedirectURI:nil];

    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
#ifdef DEBUG
    [AVOSCloud setVerbosePolicy:kAVVerboseShow];
    [AVLogger addLoggerDomain:AVLoggerDomainIM];
    [AVLogger addLoggerDomain:AVLoggerDomainCURL];
    [AVLogger setLoggerLevelMask:AVLoggerLevelAll];
#endif
    
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version < 8.0) {
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    } else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[ConversationStore sharedInstance] dump2Local:[AVUser currentUser]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    //可选 通过统计功能追踪通过提醒打开应用的行为
    if (application.applicationState != UIApplicationStateActive) {
        [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [AVOSCloudSNS handleOpenURL:url];
}

@end
