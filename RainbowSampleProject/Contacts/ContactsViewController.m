//
//  ContactsViewController.m
//  Rainbow
//
//  Created by AsalTech on 12/13/17.
//  Copyright © 2017 AsalTech. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactsCells/ContactsTableViewCell.h"
#import "ContactDetails/ContactDetailsViewController.h"
#import "Rainbow/Rainbow.h"
@interface ContactsViewController() <UITableViewDataSource ,
                                        UITableViewDelegate,UIImagePickerControllerDelegate,
                                        UINavigationControllerDelegate,UISearchBarDelegate>

@end

@implementation ContactsViewController

{
    NSMutableArray *contactsArray;
    UIImage *image ;
    UISearchBar *searchBar;
    BOOL searchEnabled;
    NSArray *tableDataSearchArray;
}

#pragma mark - Application lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
  
    contactsArray = [NSMutableArray array];
    tableDataSearchArray=[NSMutableArray array];
    
    //[[ServicesManager sharedInstance].loginManager setUsername:@"abzour@asaltech.com" andPassword:@"Asal@123"];
    [[ServicesManager sharedInstance].loginManager setUsername:@"ndmedi@asaltech.com" andPassword:@"No@ra123"];
    [[ServicesManager sharedInstance].loginManager connect];
    [[ServicesManager sharedInstance].contactsManagerService requestAddressBookAccess];

    [self registerNotifications];

    [self setup];

}
- (void) setup {
    
    // setup tabelView
   
    // setup navigationbar
   // self.navigationController.navigationBar.barTintColor = APPLICATION_BLUE_COLOR;
    
    // Add serchbar to Navigationbar
    searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = @"People...";
    searchBar.delegate = self;
    searchBar.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView = searchBar;
    self.definesPresentationContext = YES;
  
    
}
-(void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:kLoginManagerDidLoginSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getContacts:) name:kContactsManagerServiceDidAddContact object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateContact:) name: kContactsManagerServiceDidUpdateContact object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) didLogin:(NSNotification *) notification {
    NSLog(@"DID LOGIN ");
}

-(void) getContacts:(NSNotification *) notification {
    
    Contact *contact = (Contact *)notification.object;
    if(![contactsArray containsObject:contact]){
        if (contact.fullName != nil) {
            [contactsArray addObject:contact];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contactsTableView reloadData];
    });
    
}

-(void) didUpdateContact:(NSNotification *) notification {
   // Contact *contact = (Contact *)[notification.object objectForKey:@"contact"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contactsTableView reloadData];
    });
    
}

#pragma mark - tableView Methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"ContactsCell";
    Contact *contactObj;
    ContactsTableViewCell *cell = (ContactsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"ContactsTableViewCell" bundle:nil] forCellReuseIdentifier:simpleTableIdentifier];
        cell= [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(searchEnabled) {
         contactObj = [tableDataSearchArray objectAtIndex:indexPath.row];

    }
    else {
         contactObj = [contactsArray objectAtIndex:indexPath.row];
    }
    //fill data
    [cell initWithContactInfo:contactObj];
    cell.detailsButton.tag = indexPath.row;
    [cell.detailsButton addTarget:self action:@selector(moveToDetails:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searchEnabled) {
        return [tableDataSearchArray count];
    }
    else
    return [contactsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
}

#pragma mark - SearchBar delegates
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar.text.length == 0) {
        searchEnabled = NO;
        [self.contactsTableView reloadData];
    }
    else {
        searchEnabled = YES;
        NSLog(@"SearchedTxt %@",searchText);
        [self filterContentForSearchText:searchBar.text];

    }
}
- (void)filterContentForSearchText:(NSString*)searchText
{
 
    /*NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"fullName CONTAINS %@",
                                    searchText];*/
    [self searchRemotly:searchText];
   
}
//Add method to searchRemotly
-(void) searchRemotly:(NSString*)searchText
{
    [[ServicesManager sharedInstance].contactsManagerService searchRemoteContactsWithPattern:searchText withCompletionHandler:^(NSString *searchPattern, NSArray<Contact *> *foundContacts) {
        dispatch_async(dispatch_get_main_queue(), ^{
            tableDataSearchArray = [NSMutableArray arrayWithArray:foundContacts];
            [self.contactsTableView reloadData];
        });
    }];
}


#pragma mark - Actions

- (IBAction)moveToDetails:(UIButton *)sender
{
    NSInteger rowOfTheCell = sender.tag;
    NSLog(@"rowofthecell %ld", (long)rowOfTheCell);
   // ContactDetailsViewController * newView = [[ContactDetailsViewController alloc] initWithNibName:@"ContactDetailsViewController" bundle:nil];
    
//    newView.testTxt= [NSString stringWithFormat:@"Pressed Row is %ld",(long)rowOfTheCell];
//    // New line
//    [self.navigationController pushViewController:newView animated:YES];
    //open camera  store image
    @try {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    //picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
}

#pragma mark - imagePicker Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Access the uncropped image from info dictionary
    image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
 @end
 
 
