//
//  AppDelegate.m
//  RainbowSampleProject
//
//  Created by AsalTech on 12/17/17.
//  Copyright © 2017 AsalTech. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "ContactsViewController.h"
#import "ConversationsViewController.h"
#import "LoginViewController.h"
#import "Rainbow/Rainbow.h"


@interface AppDelegate ()
{
 UISearchBar *searchBar;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   // self.navigationController = [[UINavigationController alloc] initWithRootViewController:[self setupTabbarController]];
   // LoginViewController* loginView=[[LoginViewController alloc]init];
   // self.navigationController = [[UINavigationController alloc] initWithRootViewController:loginView];
    MyUser*  currentUser=[ServicesManager sharedInstance].myUser;
    if(!currentUser.username) {
        LoginViewController* loginView=[[LoginViewController alloc]init];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:loginView];
    }
    else {
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:[self setupTabbarController]];

    }
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setBarTintColor:NAVIGATION_BAR_COLOR];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (UITabBarController *) setupTabbarController{
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    UIViewController *contactsViewCntroller = [[ContactsViewController alloc] init];
    UINavigationController *contactsNavigationViewCntroller = [[UINavigationController alloc]initWithRootViewController:contactsViewCntroller];
    
    contactsNavigationViewCntroller.tabBarItem.title = @"Contacts" ;
    contactsNavigationViewCntroller.tabBarItem.image = [UIImage imageNamed:@"contacts-icons"];
    contactsNavigationViewCntroller.tabBarItem.selectedImage=[UIImage imageNamed:@"contacts-selected-icon"];
    
    UIViewController *conversationsViewController = [[ConversationsViewController alloc] init];
    UINavigationController *conversationsNavigationViewController = [[UINavigationController alloc]initWithRootViewController:conversationsViewController];
    
    conversationsNavigationViewController.tabBarItem.title=@"Conversations" ;
    conversationsNavigationViewController.tabBarItem.image = [UIImage imageNamed:@"conversations-icon"];
    conversationsNavigationViewController.tabBarItem.selectedImage=[UIImage imageNamed:@"conversations-selected-icon"];

    [tabBarController setViewControllers:[NSArray arrayWithObjects:contactsNavigationViewCntroller,conversationsNavigationViewController,nil]];
    
    return tabBarController;
    
}

@end
