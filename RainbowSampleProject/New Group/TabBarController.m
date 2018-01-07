//
//  ViewController.m
//  Rainbow
//
//  Created by AsalTech on 12/11/17.
//  Copyright © 2017 AsalTech. All rights reserved.
//

#import "TabBarController.h"
#import "ContactsViewController.h"
#import "ConversationsViewController.h"
#import "Constants.h"
@interface TabBarController ()
{
    
}



@end

@implementation TabBarController
#pragma mark - Application lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
  
    ContactsViewController * contactsController = [[ContactsViewController alloc]initWithNibName:@"ContactsViewController" bundle:nil];
    ConversationsViewController *conversationsController = [[ConversationsViewController alloc]initWithNibName:@"ConversationsViewController" bundle:nil];
    contactsController.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"Contacts" image:[UIImage imageNamed:@"contacts-icons"]tag:0];
    conversationsController.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"Conversations" image:[UIImage imageNamed:@"conversations-icon"]tag:1 ];
    NSArray* tabViewControllers= @[contactsController,conversationsController];
    [self setViewControllers:tabViewControllers];
    [[UITabBar appearance] setTintColor:NAVIGATION_BAR_COLOR];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
