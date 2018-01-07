//
//  ConversationDetailsViewController.h
//  RainbowSampleProject
//
//  Created by AsalTech on 12/17/17.
//  Copyright © 2017 AsalTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import "Rainbow/Rainbow.h"

@interface ConversationDetailsViewController : JSQMessagesViewController <CKItemsBrowserDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (strong, nonatomic) NSMutableDictionary *avatars;
@property (strong, nonatomic) Conversation *conversation;
@property (strong, nonatomic) UIImagePickerController *picker ;



@end
