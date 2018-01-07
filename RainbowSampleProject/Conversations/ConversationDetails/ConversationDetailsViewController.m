//
//  ConversationDetailsViewController.m
//  RainbowSampleProject
//
//  Created by AsalTech on 12/17/17.
//  Copyright © 2017 AsalTech. All rights reserved.
//

#import "ConversationDetailsViewController.h"
#import "Rainbow/Rainbow.h"
#import <CoreLocation/CoreLocation.h>
@import AVFoundation;
@import AVKit;
@interface ConversationDetailsViewController ()

@end

@implementation ConversationDetailsViewController
MyUser * currentUser;
BOOL isFetchMoreMessages;
MessagesBrowser *messagesBrowser;
UIImage* image;


- (void)viewDidLoad {
    [super viewDidLoad];//comment
    currentUser = [[ServicesManager sharedInstance] myUser];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    
    if(self.conversation.type == ConversationTypeUser){
        self.title=[(Contact *)[self.conversation peer]fullName];

    }
    else{
        self.title=self.conversation.peer.displayName;

    }
   self.picker = [[UIImagePickerController alloc] init];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear: animated];
    self.showLoadEarlierMessagesHeader = YES;
    self.messages = [NSMutableArray array];
    self.avatars=[NSMutableDictionary dictionary];
    
    
    UIImage* contImage= [UIImage imageWithData:[currentUser.contact photoData]];

    //settings avator images
    UIImage* senderImg =[JSQMessagesAvatarImageFactory circularAvatarImage:contImage withDiameter:20];
    JSQMessagesAvatarImage *jsqImage = [JSQMessagesAvatarImage avatarWithImage:senderImg];
    [self.avatars setObject:jsqImage forKey:currentUser.contact.jid];
    
    //message bubbles
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    
    //conversationHistory
    messagesBrowser = [[ServicesManager sharedInstance].conversationsManagerService messagesBrowserForConversation:self.conversation withPageSize:5 preloadMessages:YES];
    messagesBrowser.delegate = self;
    [messagesBrowser resyncBrowsingCacheWithCompletionHandler:^(NSArray *addedCacheItems, NSArray *removedCacheItems, NSArray *updatedCacheItems, NSError *error) {
        
    }];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)scrollToBottomAnimated:(BOOL)animated
{
    if ([self.collectionView numberOfSections] == 0) {
        return;
    }
    
    NSInteger items = [self.messages count];
    
    if (items > 0) {
        [self.collectionView layoutIfNeeded];
        CGRect scrollRect = CGRectMake(0, self.collectionView.contentSize.height - 1.f, 1.f, 1.f);
        [self.collectionView scrollRectToVisible:scrollRect animated:animated];
    }
}


#pragma mark - JSQMessages CollectionView DataSource

- (NSString *)senderId {
    return currentUser.contact.jid;
}

- (NSString *)senderDisplayName {
    if(self.conversation.type==ConversationTypeUser){
        return @"";
    }
    else
        return currentUser.contact.fullName;
}
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.messages count] > 0)
    return [self.messages objectAtIndex:indexPath.item];
    else
    return nil;

}
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];    
    return [self.avatars objectForKey:message.senderId];
    
    
}
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
 
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];

    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    //added to hide names for conversationTypeRoom
    if(self.conversation.type==ConversationTypeRoom){
         return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
    }
    else
        return [[NSAttributedString alloc] initWithString:@""];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did tab index is %d",(int)indexPath.row);
    JSQMessage* msg=[self.messages objectAtIndex:indexPath.row];
    if([msg isMediaMessage]){
        if([msg.media isKindOfClass:[JSQVideoMediaItem class]]){
            JSQVideoMediaItem* temp=(JSQVideoMediaItem*) msg;
        if(temp !=nil)
            NSLog(@"URL:vedioURL Is %@",((JSQVideoMediaItem*)msg.media).fileURL);
            NSURL* videoURL=((JSQVideoMediaItem*)msg.media).fileURL;
            //[NSURL URLWithString:@"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
            //((JSQVideoMediaItem*)msg.media).fileURL;
            // grab a local URL to our video
            //NSURL *videoURL = [[NSBundle mainBundle]URLForResource:@"video" withExtension:@"mp4"];
           /* @try{
            // create an AVPlayer
            AVPlayer *player = [AVPlayer playerWithURL:videoURL];
            
            // create a player view controller
            AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
            controller.player = player;
            [player play];
            
            // show the view controller
            [self addChildViewController:controller];
            [self.view addSubview:controller.view];
            controller.view.frame = self.view.frame;
            }
            @catch(NSException* err){
                NSLog(@"URL:vedioURL Is %@",err);

            }*/
        }
        else if([msg.media isKindOfClass:[JSQPhotoMediaItem class]]){
           NSLog(@"URL:Photo");
        }
    
    }
    
    
}


#pragma mark - UICollectionView DataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    id<JSQMessageData> messageItem = [collectionView.dataSource collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
    NSParameterAssert(messageItem != nil);
    
    BOOL isOutgoingMessage = [self isOutgoingMessage:messageItem];
    BOOL isMediaMessage = [messageItem isMediaMessage];
    
    NSString *cellIdentifier = nil;
    if (isMediaMessage) {
        cellIdentifier = isOutgoingMessage ? self.outgoingMediaCellIdentifier : self.incomingMediaCellIdentifier;
    }
    else {
        cellIdentifier = isOutgoingMessage ? self.outgoingCellIdentifier : self.incomingCellIdentifier;
    }

    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
  /*  else {
       // cell.accessoryButton.hidden = ![self shouldShowAccessoryButtonForMessage:msg];
    
        id<JSQMessageMediaData> messageMedia = [messageItem media];
    cell.mediaView = [messageMedia mediaView] ?: [messageMedia mediaPlaceholderView];
    NSParameterAssert(cell.mediaView != nil);
    }*/
    //added to reomve scrolling for the last message
  /*  NSIndexPath *lastCell = [NSIndexPath indexPathForItem: ([self.collectionView numberOfItemsInSection: 0] - 1) inSection: 0];
    
    [self.collectionView scrollToItemAtIndexPath: lastCell
                                atScrollPosition: UICollectionViewScrollPositionBottom
                                        animated: NO];*/
    

    return cell;
}


#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    
    /*JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    [self.messages addObject:message];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [ self.collectionView reloadData];
    });*/
    
   //function to send message
    [self sendMessage:text withFile:nil withMsgType: 0];
    [self finishSendingMessageAnimated:YES];
}
-(void)sendMessage:(NSString*)text withFile:(File*)file withMsgType:(int)msgtype {
    
    if(msgtype == 0) {
    [[ServicesManager sharedInstance].conversationsManagerService sendMessage:text fileAttachment:nil to:self.conversation completionHandler:^(Message *message, NSError *error) {
        JSQMessage *msg = [[JSQMessage alloc ] initWithSenderId:currentUser.contact.jid
                                              senderDisplayName:currentUser.contact.fullName
                                              date:message.date
                                              text:text];
        [self.messages addObject:msg];
     } attachmentUploadProgressHandler:^(Message *message, double totalBytesSent, double totalBytesExpectedToSend) {
         NSLog(@"total byte send  : %f",totalBytesSent);
         NSLog(@"total byte expected to send  : %f",totalBytesExpectedToSend);
         dispatch_async(dispatch_get_main_queue(), ^{
             [ self.collectionView reloadData];
             
         });
         
     }];
    }
    //attachment file
    else {
        [[ServicesManager sharedInstance].conversationsManagerService sendMessage:nil fileAttachment:file to:self.conversation completionHandler:^(Message *message, NSError *error) {
            JSQMessage* msg = [self getJSQMessage:message withUserId:currentUser.contact.jid
                                  withDisplayName:[currentUser.contact fullName]];
            [self.messages addObject:msg];
            NSLog(@"Error in uploading %@",error);
        } attachmentUploadProgressHandler:^(Message *message, double totalBytesSent, double totalBytesExpectedToSend) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [ self.collectionView reloadData];
             });
            NSLog(@"total byte send  : %f",totalBytesSent);
            NSLog(@"total byte expected to send  : %f",totalBytesExpectedToSend);
            
        }];
 
    }
}
- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Media messages", nil)
                                                       delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                       destructiveButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"Send photo", nil), NSLocalizedString(@"Send video", nil), NSLocalizedString(@"Send audio", nil), nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}
//function to handle actionSheet press btn
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    
    switch (buttonIndex) {
      case 0:
        NSLog(@"Pressed: Photo");
         @try {
                self.picker.delegate = self;
                self.picker.allowsEditing = YES;
                self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:self.picker animated:YES completion:NULL];
            }
            @catch (NSException * e) {
                NSLog(@"Exception: %@", e);
            }
     break;
            
      case 1:
            NSLog(@"Pressed: Video");
      break;
            
      case 2:
            NSLog(@"Pressed: Audio");
       break;
    }
    
    
    //[self finishSendingMessageAnimated:YES];
}
#pragma mark - imagePicker Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if(image !=nil) {
     FileSharingService* fileSharingService=[[FileSharingService alloc]init];
     File* attachedFile= [fileSharingService createTemporaryFileWithFileName:@"testImg" andData:UIImagePNGRepresentation(image)];
     [self sendMessage:nil withFile:attachedFile withMsgType:1];

     [self dismissViewControllerAnimated:YES completion:^{
         NSLog(@"Messages: len %lu",(unsigned long)[self.messages count]);
     }];
    }
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //[self dismissModalViewControllerAnimated:YES];
   [self dismissViewControllerAnimated: YES completion: nil];
}
#pragma mark - JSQMessages collection view flow layout delegate
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - messageBrowser delgate
-(void) itemsBrowser:(CKItemsBrowser*)browser didAddCacheItems:(NSArray*)newItems atIndexes:(NSIndexSet*)indexes {

      JSQMessage* customMsg;

        for (int i=0 ; i<(int)newItems.count ;i++){
            Message *message=(Message *)[newItems objectAtIndex:(int)newItems.count-1-i];
            if([[message peer] isKindOfClass:[Contact class]]) {
                Contact* contact=(Contact *)[message peer];
                UIImage* contImage= [UIImage imageWithData:[(Contact *)[message peer] photoData]];
                if(contImage != nil) {
                UIImage* peerImg =[JSQMessagesAvatarImageFactory circularAvatarImage:contImage withDiameter:20];
                [self.avatars setObject:[JSQMessagesAvatarImage avatarWithImage:peerImg] forKey:[contact jid]];
                 }
                
                if(message.isOutgoing)
                {
                   customMsg=[self getJSQMessage:message withUserId:currentUser.contact.jid
                                                         withDisplayName:[currentUser.contact fullName]];
                }
                else {
                    
                    customMsg=[self getJSQMessage:message withUserId:[contact jid]
                                                          withDisplayName:[contact fullName]];
                }
                [self.messages insertObject:customMsg atIndex:i];
            }
        }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!isFetchMoreMessages) {
            [ self.collectionView reloadData];
            NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:rowIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
            
        }
        
        
    });
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [ self.collectionView reloadData];
        [self scrollToBottomAnimated:NO];
    });*/
    
    NSLog(@"Browser: didAddCacheItems!");
    NSLog(@"Browser: MesssagesLength %lu !",(unsigned long)[newItems count]);
}

-(void) itemsBrowser:(CKItemsBrowser*)browser didRemoveCacheItems:(NSArray*)removedItems atIndexes:(NSIndexSet*)indexes{
    NSLog(@"Browser: Removed!");
}
-(void) itemsBrowser:(CKItemsBrowser*)browser didUpdateCacheItems:(NSArray*)changedItems atIndexes:(NSIndexSet*)indexes {
    
   
   /*dispatch_async(dispatch_get_main_queue(), ^{
        [self.messages replaceObjectsAtIndexes:indexes withObjects:changedItems];
        [ self.collectionView reloadData];
        
    });*/
    NSLog(@"Browser: didUpdateCacheItems!");
}

-(void) itemsBrowser:(CKItemsBrowser*)browser didReorderCacheItemsAtIndexes:(NSArray*)oldIndexes toIndexes:(NSArray*)newIndexes {
    NSLog(@"Browser: Reorderd!");
}

-(void) itemsBrowser:(CKItemsBrowser*)browser didReceiveItemsAddedEvent:(NSArray*)addedItems{
    
    NSLog(@"Browser: ReceivedItemsAdded!");
}

-(void) itemsBrowser:(CKItemsBrowser*)browser didReceiveItemsDeletedEvent:(NSArray*)deletedItems{
    
    NSLog(@"Browser: ReceivedItemsDeleted!");
}

-(void) itemsBrowserDidReceivedAllItemsDeletedEvent:(CKItemsBrowser*)browser{
    
    NSLog(@"Browser: ReceivedAllItemsDeleted!");
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    
    //[headerView.loadButton setTitle:@"Load More.." forState:UIControlStateNormal];
     isFetchMoreMessages = YES;
    NSLog(@"Browser:Load earlier messages!");
    [messagesBrowser nextPageWithCompletionHandler:^(NSArray *addedCacheItems, NSArray *removedCacheItems, NSArray *updatedCacheItems, NSError *error) {
        
         dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        if (addedCacheItems.count) {
            isFetchMoreMessages = NO;
            NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:rowIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
             //scrollToRowAtIndexPath:rowIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
        
          });
    }];
    
    
}


#pragma mark - GetMediaJSQMessage
-(JSQMessage*) getJSQMessage:(Message*) message withUserId:(NSString*)userId withDisplayName:(NSString*)name {
  NSLog(@"retID %@ %@",userId,name);
  JSQMessage* returnedMsg;
  if(message.attachment!=nil) {
    NSArray* type;
    type=[message.attachment.mimeType componentsSeparatedByString:@"/"];
    if ([type[0] isEqualToString:@"video"]){
        JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:message.attachment.url isReadyToPlay:YES];
        returnedMsg = [JSQMessage messageWithSenderId:userId displayName:name media:videoItem];
   
    }
    else if([type[0] isEqualToString:@"image"]){
        UIImage *img = [[UIImage alloc] initWithData:message.attachment.data];
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:img];
        returnedMsg=[JSQMessage messageWithSenderId:userId displayName:name media:photoItem];
        
    }
    else if([type[0] isEqualToString:@"audio"]){
      NSLog(@"type11: MessageIsAudio");
        NSString * sample = [[NSBundle mainBundle] pathForResource:@"jsq_messages_sample" ofType:@"m4a"];
        NSData * audioData = [NSData dataWithContentsOfFile:sample];
        JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithData:audioData];
        returnedMsg= [JSQMessage messageWithSenderId:userId displayName:name media:audioItem];
     }
}
    else {
        NSLog(@"type11: MessageIsText");
        returnedMsg= [[JSQMessage alloc] initWithSenderId:userId
                                         senderDisplayName:name
                                         date:[message date]
                                         text:NSLocalizedString([message body], nil)];
    }

    return returnedMsg;

}


@end
