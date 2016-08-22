//
//  ShakeToPlayViewController.h
//  TextMuse
//
//  Created by Peter Tucker on 8/9/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICaptionButton.h"
#import "UICheckButton.h"
#import "Message.h"
#import "UserContact.h"
#import "SendMessage.h"

@interface ShakeToPlayViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource> {
    IBOutlet UIButton* btnContactLock;
    IBOutlet UIButton* btnTextLock;
    IBOutlet UIPickerView* pickerContacts;
    IBOutlet UIPickerView* pickerTexts;
    
    BOOL recentContacts;
    
    UICheckButton* chkRecentContacts;
    UICaptionButton* btnSendIt;
    
    SendMessage* sendMessage;
}

-(IBAction)lock:(id)sender;

@end
