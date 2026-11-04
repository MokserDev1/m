//
//  AppDelegate.m
//  Zmeyka
//

#import "AppDelegate.h"
#import "MenuViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[MenuViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Free memory or state if needed.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Undo changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate.
}

@end

