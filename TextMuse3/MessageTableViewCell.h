//
//  MessageTableViewCell.h
//  TextMuse
//
//  Created by Peter Tucker on 12/26/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SponsorInfo.h"
#import "Message.h"
#import "ImageDownloader.h"
#import "UICaptionButton.h"
#import "SendMessage.h"

@interface MessageTableViewCell : UITableViewCell {
    ImageDownloader* downloader;

    CGRect frmParent;
    CGRect frmLogo;
    CGRect frmTitle;
    CGRect frmSeeAll;
    CGRect frmLike;
    CGRect frmPin;
    CGRect frmSend;
    CGRect frmContent;
    UIView* viewParent;
    Message* _msg;
    UINavigationController* _nav;
    SendMessage* sendMessage;
    
    UITableView* _tableView;
    
    IBOutlet UILabel* lblContent;
    IBOutlet UILabel* lblTitle;
    IBOutlet UIImageView* imgLogo;
    IBOutlet UIButton* btnSeeAll;
    IBOutlet UICaptionButton* btnLike;
    IBOutlet UICaptionButton* btnPin;
    IBOutlet UICaptionButton* btnSend;
}

+(CGSize) GetContentSizeForImage:(UIImage*) img inSize:(CGSize)sizeParent;
+(CGFloat) GetCellHeightForMessage:(Message*)msg inSize:(CGSize)size;

-(void)showForSize:(CGSize)size
       usingParent:(id)nav
         withColor:(UIColor*)color
         textColor:(UIColor*)colorText
        titleColor:(UIColor*)colorTitle
             title:(NSString*)title
           sponsor:(SponsorInfo*)sponsor
           message:(Message*)msg;
-(void)setTableView:(UITableView*)tableView;

@end
