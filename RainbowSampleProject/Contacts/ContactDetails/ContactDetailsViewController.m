//
//  ContactDetailsViewController.m
//  RainbowSampleProject
//
//  Created by AsalTech on 12/17/17.
//  Copyright © 2017 AsalTech. All rights reserved.
//

#import "ContactDetailsViewController.h"

@interface ContactDetailsViewController ()
@property (nonatomic) NSInteger pressedRow;
@end

@implementation ContactDetailsViewController
@synthesize testLabel=_testLabel;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.testLabel.text=_testTxt;
    // Do any additional setup after loading the view from its nib.
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

@end
