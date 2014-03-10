//
//  ParseAppDelegate.m
//  ParseApp
//
//  Created by Ziyang Tan on 5/31/13.
//  Copyright (c) 2013 Ziyang Tan. All rights reserved.
//

#import "ParseAppDelegate.h"
#import <Parse/Parse.h>
#import "ParseListViewController.h"
#import "ParseCompletedListViewController.h"

@implementation ParseAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Parse API setup
    [Parse setApplicationId:@"Ish6JeJ8VxiMf7ldbTmODKNHSUeHXwSWUFunAQIj"
                  clientKey:@"3UOK5rxB70tcVtkrpipoJ0pIxgUy5cU5Y88SgH0a"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    // reset badge
    application.applicationIconBadgeNumber = 0;
        
    // Initialize List View Controller
    ParseListViewController *listViewController = [[ParseListViewController alloc] init];
    // Initialize Navigation Controller
    UINavigationController *listNavigationController = [[UINavigationController alloc] initWithRootViewController:listViewController];
    // Initialize Shopping List View Controller
    ParseCompletedListViewController *completedListViewController = [[ParseCompletedListViewController alloc] init];
    // Initialize Navigation Controller
    UINavigationController *completedListNavigationController = [[UINavigationController alloc] initWithRootViewController:completedListViewController];
    
    // Custom Tab bar icons
    UITabBarItem *tab1 = [[UITabBarItem alloc] initWithTitle:@"To Do List" image:[UIImage imageNamed:@"list"] tag:1];
    [listNavigationController setTabBarItem:tab1];
    listNavigationController.navigationBar.tintColor = [UIColor blackColor];
    
    UITabBarItem *tab2 = [[UITabBarItem alloc] initWithTitle:@"Completed List" image:[UIImage imageNamed:@"check"] tag:2];
    [completedListNavigationController setTabBarItem:tab2];
    
    CGFloat nRed=18.0;
    CGFloat nBlue=186.0;
    CGFloat nGreen=187.0;
    UIColor *btnColor = [[UIColor alloc] initWithRed: nRed green: nBlue blue:nGreen alpha:1.0];

    completedListNavigationController.navigationBar.tintColor = btnColor;
    
    [completedListViewController setMyListView:listViewController];

    // Initialize Tab Bar Controller
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    // Configure Tab Bar Controller
    [tabBarController setViewControllers:@[listNavigationController, completedListNavigationController]];
    // Initialize Window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Configure Window
    [self.window setRootViewController:tabBarController];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)arrangeBadgeNumbers{
    _notificationsArray = [NSMutableArray arrayWithArray:[[UIApplication sharedApplication] scheduledLocalNotifications]];
    NSLog(@"notifications array count: %d",_notificationsArray.count);
    NSMutableArray *fireDates = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i< _notificationsArray.count; i++)
    {
        UILocalNotification *notif = [self.notificationsArray objectAtIndex:i];
        NSDate *firedate = notif.fireDate;
        [fireDates addObject:firedate];
    }
    NSArray *sortedFireDates= [fireDates sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSInteger i=0; i< _notificationsArray.count; i++)
    {
        UILocalNotification *notif = [_notificationsArray objectAtIndex:i];
        notif.applicationIconBadgeNumber=[sortedFireDates indexOfObject:notif.fireDate]+1;
    }
    [[UIApplication sharedApplication] setScheduledLocalNotifications:_notificationsArray];
    
    _notificationsArray = [NSMutableArray arrayWithArray:[[UIApplication sharedApplication] scheduledLocalNotifications]];
    for (int i  = 0; i < _notificationsArray.count; i++) {
        UILocalNotification *notif = [self.notificationsArray objectAtIndex:i];
        NSLog(@"appdelegate objectId %@, fileDate %@", [notif.userInfo valueForKey:@"Notification"], notif.fireDate);
    }
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [self arrangeBadgeNumbers];

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notif {
	// Handle the notificaton when the app is running
    
    NSLog(@"did receive notif");
    // reset the badge
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notif.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

    application.applicationIconBadgeNumber = 0;

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
    [self arrangeBadgeNumbers];
}

@end
