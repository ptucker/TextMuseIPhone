//
//  TextMessageTableViewCell.h
//  TextMuse
//
//  Created by Peter Tucker on 12/26/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTableViewCell.h"

@interface TextMessageTableViewCell : MessageTableViewCell {
    IBOutlet UIImageView* imgLeftQuote;
    IBOutlet UIImageView* imgRightQuote;
    IBOutlet UIImageView* imgBubble;
}

@end
