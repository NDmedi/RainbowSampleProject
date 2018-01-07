//
//  ContactsTableViewCell.m
//  Rainbow
//
//  Created by AsalTech on 12/13/17.
//  Copyright © 2017 AsalTech. All rights reserved.
//

#import "ContactsTableViewCell.h"
#import "ContactDetailsViewController.h"
#import "Rainbow/Rainbow.h"
#import "Constants.h"
@implementation ContactsTableViewCell

@synthesize contactImageView=_contactImageView;
@synthesize contactNameLabel=_contactNameLabel;
@synthesize contactStatusLabel=_contactStatusLabel;
@synthesize detailsButton=_detailsButton;
@synthesize coloredLabel=_coloredLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.coloredLabel.clipsToBounds = YES;
    self.coloredLabel.layer.borderWidth = 1.0f;
    self.coloredLabel.layer.cornerRadius = self.coloredLabel.frame.size.width / 2;
    self.coloredLabel.layer.borderColor = WHITE.CGColor;   
    self.contactImageView.layer.cornerRadius = (self.contactImageView.frame.size.width) / 2;
    self.contactImageView.clipsToBounds = YES;
    self.coloredLabel.layer.cornerRadius = self.coloredLabel.frame.size.width / 2;
    self.coloredLabel.clipsToBounds = YES;
    self.coloredLabel.layer.borderWidth = 1.0f;
    self.coloredLabel.layer.borderColor = WHITE.CGColor;
    UIImage *imgDetails = [UIImage imageNamed:@"userdetails-icon"];
    [self.detailsButton setImage:imgDetails forState:UIControlStateNormal];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void) initWithContactInfo :(Contact *)contact {
    Presence *contactPresence=[contact presence];
    self.contactNameLabel.text=[contact fullName];
    self.contactStatusLabel.text=[contactPresence status];
    if([contact photoData] != nil){
       [self.contactImageView setImage:[UIImage imageWithData:[contact photoData]]];
    }
    else {
        [self.contactImageView setImage:[UIImage imageNamed:@"avator"]];
    }
    
    //set labelcolor and status according to recieved contact object
    switch ((long)contact.presence.presence) {
        case 0:
            self.contactStatusLabel.text = UNAVAILABLE;
            self.coloredLabel.backgroundColor = STATUS_UNAVAILABLE;
            break;
        case 1:
            if (contact.isConnectedWithMobile) {
                self.contactStatusLabel.text = AVAILABLE_ON_MOBILE;
            }
            else{
                self.contactStatusLabel.text = AVAILABLE;
            }
            
            self.coloredLabel.backgroundColor = STATUS_AVAILABLE;
            break;
            
        case 2:
            self.contactStatusLabel.text = DONT_DISTURB;
            self.coloredLabel.backgroundColor = STATUS_DONT_DISTURB;
            break;
            
        case 3:
            self.contactStatusLabel.text = BUSY;
            self.coloredLabel.backgroundColor = STATUS_BUSY;
            break;
        case 4:
            self.contactStatusLabel.text = AWAY;
            self.coloredLabel.backgroundColor = STATUS_AWAY;
            break;
        case 5:
            self.contactStatusLabel.text = INVESIBLE;
            self.coloredLabel.backgroundColor = STATUS_OFFLINE;
            break;
            
        default:
            break;
    }
}
@end
