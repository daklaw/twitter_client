//
//  AppDelegate.m
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "AppDelegate.h"
#import "AuthViewController.h"
#import "HomeViewController.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

- (void)updateRootVC;

@property (nonatomic, strong) AuthViewController *authViewController;
@property (nonatomic, strong) UINavigationController *homeViewController;
@property (nonatomic, strong) UIViewController *currentVC;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRootVC) name:UserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRootVC) name:UserDidLogoutNotification object:nil];
    
    [Parse setApplicationId:@"gYNu7zRkFp2AvumLqeMlaxBxF0nHuJLbJAEfB5rS"
                  clientKey:@"1Texmor5QRrDAxw7Ri48N2SE64gYTpOsPttxEMMh"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [[TwitterClient instance] currentUserWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
        [User setCurrentUser:[[User alloc] initWithDictionary:response]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        AuthViewController *authViewController = [[AuthViewController alloc] init];
        
        self.window.rootViewController = authViewController;
    }];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:kAFApplicationLaunchOptionsURLKey]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    return YES;
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

#pragma mark - Private Methods

- (UIViewController *) currentVC {
    if ([User currentUser]) {
        return self.homeViewController;
    } else {
        return self.authViewController;
    }
}

- (UINavigationController *)homeViewController {
    if (!_homeViewController) {
        HomeViewController *homeViewController = [[HomeViewController alloc] init];
        _homeViewController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        _homeViewController.navigationBar.barTintColor = [UIColor colorWithRed:(85/255.0) green:(172/255.0) blue:(238/255.0) alpha:1.0];
        _homeViewController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
    return _homeViewController;
}

- (AuthViewController *)authViewController {
    if (!_authViewController) {
        _authViewController = [[AuthViewController alloc] init];
    }
    
    return _authViewController;
}

- (void)updateRootVC {
    self.window.rootViewController = self.currentVC;
}

@end
