/*
 *  © Copyright 2015 IBM Corp.
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
#import "MobileFirstBanking.h"
#import <IBMMobileFirstPlatformFoundationHybrid/IBMMobileFirstPlatformFoundationHybrid.h>
#import "Cordova/CDVViewController.h"

#import "LoginScreenViewController.h"

#define NAV_BAR_TINT_COLOR [UIColor colorWithRed:0.0/255.0 green:179.0/255.0 blue:217.0/255.0 alpha:1]
#define NAV_BAR_TEXT_FONT [UIFont fontWithName:@"Helvetica Neue" size:20]
#define NAV_BAR_TEXT_COLOR [UIColor whiteColor]

#define light_blue [UIColor colorWithRed:0.0/255.0 green:179.0/255.0 blue:217.0/255.0 alpha:0.1]

@implementation MyAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BOOL result = [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    // Set defaults for UIStatusBar and UINavigationBar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBarTintColor:NAV_BAR_TINT_COLOR];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          NAV_BAR_TEXT_COLOR,
                                                          NSForegroundColorAttributeName,
                                                          NAV_BAR_TEXT_FONT,
                                                          NSFontAttributeName, nil]];
    
    [[UINavigationBar appearance] setTintColor:NAV_BAR_TEXT_COLOR];
    
    // Create main app UI
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    LoginScreenViewController *loginScreenViewController = [[LoginScreenViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginScreenViewController];
    [navigationController setNavigationBarHidden:YES];
    // Show application UI
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    return result;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
