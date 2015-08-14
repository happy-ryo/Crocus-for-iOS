/*
 * Copyright (C) 2014 happy_ryo
 *      https://twitter.com/happy_ryo
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AppDelegate.h"
#import "Parse.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse enableLocalDatastore];

    [Fabric with:@[CrashlyticsKit]];

    // Initialize Parse.
    [Parse setApplicationId:@"LzHEwVYvwESqmpVYfVDsQbyEKfSLlSuCg2C6ovPi"
                  clientKey:@"QzXNRfQgMj6kW4t4EfgB8sVZB9j4X0P2EaY4WqDj"];

    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [PFPurchase addObserverForProduct:@"info.happyryo.crocus.adblocking" block:^(SKPaymentTransaction *transaction) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"adblocking"];
        [userDefaults synchronize];
    }];

    UIUserNotificationType types =
            UIUserNotificationTypeBadge |
                    UIUserNotificationTypeSound |
                    UIUserNotificationTypeAlert;

    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];

    [application registerUserNotificationSettings:mySettings];
    [application registerForRemoteNotifications];

    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:@"3ccdbbfeafcb41ee8590cad2983b141a" clientSecret:@"aafeafde-bd75-4496-8996-b7bcfeb67432" enableSignUp:NO];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateActive) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        application.applicationIconBadgeNumber = 0;
        PFInstallation *installation = [PFInstallation currentInstallation];
        installation.badge = 0;
        installation.saveInBackground;
    } else if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        [PFPush handlePush:userInfo];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    UIUserNotificationType types =
            UIUserNotificationTypeBadge |
                    UIUserNotificationTypeSound |
                    UIUserNotificationTypeAlert;

    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];

    [application registerUserNotificationSettings:mySettings];
    [application registerForRemoteNotifications];

    application.applicationIconBadgeNumber = 0;
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation.badge = 0;
    installation.saveInBackground;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

@end
