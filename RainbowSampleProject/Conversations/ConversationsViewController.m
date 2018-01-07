//
//  ConversationsViewController.m
//  Rainbow
//
//  Created by AsalTech on 12/13/17.
//  Copyright © 2017 AsalTech. All rights reserved.
//

#import "ConversationsViewController.h"
#import "ConversationsCells/ConversationTableViewCell.h"
#import "ConversationDetails/ConversationDetailsViewController.h"
#import "Rainbow/Rainbow.h"
  
@interface ConversationsViewController () <UITableViewDataSource ,UITableViewDelegate,UISearchBarDelegate>

@end

@implementation ConversationsViewController
NSArray *contactNames;
NSArray *contactStatus;
UISearchBar *searchBar;
BOOL searchEnabled;
NSArray *tableDataSearchArray;
NSArray<Conversation *> *conversationsArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    
}
-(void)setUp {
    // Do any additional setup after loading the view from its nib.
    contactNames = [NSArray arrayWithObjects:@"Contact1", @"Contact2", @"Contact3", @"Contact4", @"Contact5", @"Contact6",  nil];
    contactStatus = [NSArray arrayWithObjects:@"Offline", @"Offline", @"Offline", @"Online", @"Online", @"Online", nil];
    tableDataSearchArray=[NSMutableArray array];
    
    // Add serchbar to Navigationbar
    searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = @"Conversations...";
    searchBar.delegate = self;
    searchBar.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView = searchBar;
    self.definesPresentationContext = YES;
   conversationsArray = [ServicesManager sharedInstance].conversationsManagerService.conversations;
   /* for(int i=0 ; i<[conversationsArray count] ; i++){
    if([[conversationsArray objectAtIndex:i].peer isKindOfClass:[Contact class]]){
        Contact *contact=(Contact *)[conversationsArray objectAtIndex:i].peer;
        NSLog(@"contactInfo %@",[ contact fullName]);
    };
    }*/

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)regiesterNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateConversation:) name:kConversationsManagerDidUpdateConversation object:nil];

}
-(void) didUpdateConversation:(NSNotification *) notification {
    //Conversation * updatedConversation = (Conversation *)notification.object
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"ConversationTableViewCell";
    Conversation *conversationObj;

    NSLog(@"indexPath : %li",(long)indexPath.row);
    ConversationTableViewCell *cell = (ConversationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"ConversationTableViewCell" bundle:nil] forCellReuseIdentifier:simpleTableIdentifier];
        cell= [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }
   
    if(searchEnabled) {
        conversationObj = [tableDataSearchArray objectAtIndex:indexPath.row];
     }
    else {
        conversationObj = [conversationsArray objectAtIndex:indexPath.row];
    }
    //fill data
    [cell initWithConversationInfo:conversationObj];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(searchEnabled) {
        return [tableDataSearchArray count];

    }
    else {
        return [conversationsArray count];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"CellHeight %li",indexPath.row);
    return 64.0;
    // This is just Programatic method you can also do that by xib !
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    ConversationDetailsViewController * newView = [[ConversationDetailsViewController alloc] initWithNibName:@"ConversationDetailsViewController" bundle:nil];
    newView.conversation=[conversationsArray objectAtIndex:indexPath.row];
    newView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newView animated:YES];
    
}
#pragma mark - SearchBar delegates
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar.text.length == 0) {
        searchEnabled = NO;
        [self.conversationsTableView reloadData];
    }
    else {
        searchEnabled = YES;
        NSLog(@"SearchedTxt %@",searchText);
        [self filterContentForSearchText:searchBar.text];
        
    }
}
- (void)filterContentForSearchText:(NSString*)searchText
{
    
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"self.peer.displayName CONTAINS %@",
                                    searchText];
    
    tableDataSearchArray = [conversationsArray filteredArrayUsingPredicate:resultPredicate];
    [self.conversationsTableView reloadData];
}

@end
