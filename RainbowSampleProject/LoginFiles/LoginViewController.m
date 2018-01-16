//
//  LoginViewController.m
//  RainbowSampleProject
//
//  Created by AsalTech on 1/14/18.
//  Copyright © 2018 AsalTech. All rights reserved.
//

#import "LoginViewController.h"
#import "APLoadingButton.h"
#import "Rainbow/Rainbow.h"
#import "ContactsViewController.h"
#import "ConversationsViewController.h"+
#import "Constants.h"
@interface LoginViewController ()<UITextFieldDelegate>
{
    APLoadingButton *loginButton;
    UIImageView *backgroundImage;
    UITextField *username,*password;
}
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;

@end
@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createPresentControllerButton];
  

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)createPresentControllerButton{
    
    [_backgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background1.jpg"]]];
    //Added Login Button
    loginButton = [[APLoadingButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 350), [UIScreen mainScreen].bounds.size.width - 40, 40)];
    [loginButton setBackgroundColor:[UIColor purpleColor]];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(PresentViewController:) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:loginButton];
    
    username = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 450), [UIScreen mainScreen].bounds.size.width - 40, 40)];
    username.borderStyle = UITextBorderStyleRoundedRect;
    username.font = [UIFont systemFontOfSize:15];
    username.placeholder = @"Username";
    username.autocorrectionType = UITextAutocorrectionTypeNo;
    username.returnKeyType = UIReturnKeyDone;
    username.clearButtonMode = UITextFieldViewModeWhileEditing;
    username.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    username.delegate = self;
    [_backgroundView addSubview:username];
    
    password = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 400), [UIScreen mainScreen].bounds.size.width - 40, 40)];
    password.borderStyle = UITextBorderStyleRoundedRect;
    password.font = [UIFont systemFontOfSize:15];
    password.placeholder = @"Password";
    password.autocorrectionType = UITextAutocorrectionTypeNo;
    password.returnKeyType = UIReturnKeyDone;
    password.clearButtonMode = UITextFieldViewModeWhileEditing;
    password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    password.secureTextEntry = true;
    password.delegate = self;
    [_backgroundView addSubview:password];
    
    
    UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 500), [UIScreen mainScreen].bounds.size.width - 40, 40)];
    fromLabel.text = @"Please enter all TextField";
    fromLabel.numberOfLines = 1;
    fromLabel.font = [UIFont systemFontOfSize:17];
    fromLabel.adjustsFontSizeToFitWidth = YES;
    fromLabel.minimumScaleFactor = 10.0f/12.0f;
    fromLabel.clipsToBounds = YES;
    fromLabel.backgroundColor = [UIColor clearColor];
    fromLabel.textColor = [UIColor whiteColor];
    fromLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:fromLabel];
    
    
    
}

- (void)PresentViewController:(APLoadingButton *)button
{
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (username.text  && [password.text length] > 1 )
        {
            //register notification
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginSucceed:) name: kLoginManagerDidLoginSucceeded object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginFailed:) name: kLoginManagerDidFailedToAuthenticate object:nil];
            [[ServicesManager sharedInstance].loginManager setUsername:username.text andPassword:password.text];
            [[ServicesManager sharedInstance].loginManager connect];
            
        }
        else{
            [button failedAnimationWithCompletion:^{
            }];
        }
    });
}

#pragma mark - textInputs delegates
-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:username])
    {
        NSLog(@"test: username");
        
    }
    else {
      NSLog(@"test: password");
    }
}

#pragma mark - loginNotifications
-(void) didLoginSucceed:(NSNotification *) notification {
    NSLog(@"login: Success");
    [[ServicesManager sharedInstance].contactsManagerService requestAddressBookAccess];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [loginButton succeedAnimationWithCompletion:^{
    [[UITabBar appearance] setTintColor:NAVIGATION_BAR_COLOR];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setTitleTextAttributes:
    [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController pushViewController:[self setupTabbarController] animated:YES];
       
    }];
         });
   
    
   
}
-(void) didLoginFailed:(NSNotification *) notification {
   NSLog(@"login: Failed");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [loginButton failedAnimationWithCompletion:^{
        }];
    });
    
}
#pragma mark - setUp BartabController
- (UITabBarController *) setupTabbarController{
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    UIViewController *contactsViewController = [[ContactsViewController alloc] init];
    UINavigationController *contactsNavigationViewCntroller = [[UINavigationController alloc]initWithRootViewController:contactsViewController];
    
    contactsNavigationViewCntroller.tabBarItem.title = @"Contacts" ;
    contactsNavigationViewCntroller.tabBarItem.image = [UIImage imageNamed:@"contacts-icons"];
    contactsNavigationViewCntroller.tabBarItem.selectedImage=[UIImage imageNamed:@"contacts-selected-icon"];
    
    UIViewController *conversationsViewController = [[ConversationsViewController alloc] init];
    UINavigationController *conversationsNavigationViewController = [[UINavigationController alloc]initWithRootViewController:conversationsViewController];
    
    conversationsNavigationViewController.tabBarItem.title=@"Conversations" ;
    conversationsNavigationViewController.tabBarItem.image = [UIImage imageNamed:@"conversations-icon"];
    conversationsNavigationViewController.tabBarItem.selectedImage=[UIImage imageNamed:@"conversations-selected-icon"];
    
    [tabBarController setViewControllers:[NSArray arrayWithObjects:contactsNavigationViewCntroller,conversationsNavigationViewController,nil]];
     [[NSNotificationCenter defaultCenter] addObserver:contactsViewController selector:@selector(getContacts:) name:kContactsManagerServiceDidAddContact object:nil];
    return tabBarController;
    
}
@end
