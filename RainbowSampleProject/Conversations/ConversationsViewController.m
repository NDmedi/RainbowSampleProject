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
  
@interface ConversationsViewController () <UITableViewDataSource ,UITableViewDelegate,UISearchBarDelegate>{
    BOOL searchEnabled;
    NSMutableArray *tableDataSearchArray;
    NSArray<Conversation *> *conversationsArray;
    UISearchBar *searchBar;
}

@end

@implementation ConversationsViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    
}

-(void)setUp {
    
    tableDataSearchArray=[NSMutableArray array];
    
    // Add serchbar to Navigationbar
    searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = @"Conversations...";
    searchBar.delegate = self;
    searchBar.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView = searchBar;
    self.definesPresentationContext = YES;
    conversationsArray = [ServicesManager sharedInstance].conversationsManagerService.conversations;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMessage:) name:kConversationsManagerDidReceiveNewMessageForConversation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateConversation:) name:kConversationsManagerDidUpdateConversation object:nil];
    
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // TODO:  change this, instead use notifications ..
    long noOfUnreadMsgs=[ServicesManager sharedInstance].conversationsManagerService.totalNbOfUnreadMessagesInAllConversations;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(noOfUnreadMsgs!=0)
            [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld",noOfUnreadMsgs];
        else
             [[self navigationController] tabBarItem].badgeValue = nil;
        // this is to update conversation when back from chat ..
        [self.conversationsTableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView Delgates and dataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"ConversationTableViewCell";
    
    ConversationTableViewCell *cell = (ConversationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"ConversationTableViewCell" bundle:nil] forCellReuseIdentifier:simpleTableIdentifier];
        cell= [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }
    
    Conversation *conversationObj;
    
    if(searchEnabled) {
        conversationObj = [tableDataSearchArray objectAtIndex:indexPath.row];
     }
    else {
        conversationObj = [conversationsArray objectAtIndex:indexPath.row];
    }
       
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
    return 64.0;
   
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
    tableDataSearchArray = [NSMutableArray arrayWithArray:conversationsArray];
    [tableDataSearchArray filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Conversation * evaluatedObject, NSDictionary *bindings) {
        
        if ([evaluatedObject.peer isKindOfClass:[Contact class]]) {
            Contact * contact = (Contact *) evaluatedObject.peer;
            return [contact.fullName localizedCaseInsensitiveContainsString:searchBar.text];
        }
        return [evaluatedObject.peer.displayName localizedCaseInsensitiveContainsString:searchBar.text];
    }]];
    dispatch_async(dispatch_get_main_queue(), ^{
         [self.conversationsTableView reloadData];
    });
}

#pragma mark - RecieveNewMessage Notification

- (void) didReceiveNewMessage : (NSNotification *) notification {
    long noOfUnreadMsgs=[ServicesManager sharedInstance].conversationsManagerService.totalNbOfUnreadMessagesInAllConversations;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(noOfUnreadMsgs!=0){
             [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld",noOfUnreadMsgs];
        }
        else
            [[self navigationController] tabBarItem].badgeValue = nil;
        [self.conversationsTableView reloadData];
    });
}

-(void) didUpdateConversation:(NSNotification *) notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationsTableView reloadData];
    });
    
}
@end
