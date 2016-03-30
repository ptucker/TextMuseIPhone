//
//  ImageMessageTableViewCell.h
//  TextMuse
//
//  Created by Peter Tucker on 12/26/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTableViewCell.h"
#import "FLAnimatedImage.h"

@interface ImageMessageTableViewCell : MessageTableViewCell {
    IBOutlet UIImageView* imgContent;
}

-(void)setMsgImage:(Message*)msg forFrame:(CGRect)frmContentImage withDefault:(UIImage*)img;

@end
