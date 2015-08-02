//
//  UISuggestionButton.h
//  TextMuse
//
//  Created by Peter Tucker on 8/2/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface UISuggestionButton : UIButton {
    UILabel* lblText;
    UIImageView* img;
    Message* message;
}

-(id)initWithMessage:(Message*)msg;

@property (readonly) Message* message;

@end
