//
//  ConversationTableViewCell.m
//  RainbowSampleProject
//
//  Created by AsalTech on 12/17/17.
//  Copyright © 2017 AsalTech. All rights reserved.
//

#import "ConversationTableViewCell.h"
#import "Rainbow/Rainbow.h"
#import "Constants.h"

@implementation ConversationTableViewCell
@synthesize contactImageView=_contactImageView;
@synthesize contactNameLabel=_contactNameLabel;
@synthesize statusLabel=_statusLabel;
@synthesize dateLabel=_dateLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.statusLabel.clipsToBounds = YES;
    self.statusLabel.layer.borderWidth = 1.0f;
    self.statusLabel.layer.cornerRadius = self.statusLabel.frame.size.width / 2;
    self.statusLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    // set ImageView Proparties
    self.contactImageView.layer.cornerRadius = (self.contactImageView.frame.size.width) / 2;
    self.contactImageView.clipsToBounds = YES;
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initWithConversationInfo:(Conversation *)conversation{
    
    [self.contactImageView setImage:[UIImage imageNamed:@"avator"]];
    
    if([conversation.peer isKindOfClass:[Contact class]]){
        Contact *contact=(Contact*)conversation.peer;
        self.contactNameLabel.text=[contact fullName];
        if([contact photoData] != nil){
            [self.contactImageView setImage:[UIImage imageWithData:[contact photoData]]];
        }
        else {
            [self.contactImageView setImage:[UIImage imageNamed:@"avator"]];
        }
        [self changeStausColor:(long)contact.presence.presence];
    }
    else {
        self.contactNameLabel.text=[conversation.peer displayName ];
        [self.statusLabel setHidden:YES];
    }
    
    if(conversation.unreadMessagesCount) {
        self.senderLabel.font = [UIFont boldSystemFontOfSize:10.0];
    }
    else {
        self.senderLabel.font = [UIFont systemFontOfSize:10.0];
        
    }
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"dd/MM/yyy"];
    self.dateLabel.text=[dateFormatter1 stringFromDate:[conversation.lastMessage date]];
    self.senderLabel.text=[conversation.lastMessage body];
}

-(void)changeStausColor:(long)contactPresence{
    switch (contactPresence) {
        case 0:
            self.statusLabel.backgroundColor = STATUS_UNAVAILABLE;
            break;
        case 1:
            self.statusLabel.backgroundColor = STATUS_AVAILABLE;
            break;
            
        case 2:
            self.statusLabel.backgroundColor = STATUS_DONT_DISTURB;
            break;
            
        case 3:
            self.statusLabel.backgroundColor = STATUS_BUSY;
            break;
        case 4:
            self.statusLabel.backgroundColor = STATUS_AWAY;
            break;
        case 5:
            self.statusLabel.backgroundColor = STATUS_OFFLINE;
            break;
            
        default:
            break;
    }
}


@end
