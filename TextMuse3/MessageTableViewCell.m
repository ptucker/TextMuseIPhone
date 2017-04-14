//
//  MessageTableViewCell.m
//  TextMuse
//
//  Created by Peter Tucker on 12/26/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import "MessageCategory.h"
#import "MessageTableViewCell.h"
#import "GlobalState.h"
#import "Settings.h"

NSString* urlLikeNote = @"http://www.textmuse.com/admin/notelike.php";

@implementation MessageTableViewCell

-(void)showForSize:(CGSize)size
       usingParent:(id)nav
          withColor:(UIColor*)color
          textColor:(UIColor*)colorText
         titleColor:(UIColor*)colorTitle
              title:(NSString*)title
            sponsor:(SponsorInfo*)sponsor
            message:(Message*)msg {
    _msg = msg;
    _nav = nav;
    
    CGSize sizeParent = CGSizeMake(size.width-16, 133);
    if ([msg img] != nil)
        sizeParent = [MessageTableViewCell GetContentSizeForImage:[UIImage imageWithData:[msg img]]
                                                           inSize:size];
    
    CGFloat bottomY = sizeParent.height + 40;
    
    frmTitle = CGRectMake(35, 8, size.width - 8 - 35, 21);
    frmSeeAll = CGRectMake(size.width - 14 - 8, 8, 14, 21);
    frmLike = CGRectMake(8, bottomY, 84, 21);
    frmPin = CGRectMake(size.width/2 - 46, bottomY, 92, 21);
    frmSend = CGRectMake(size.width - 8 - 84, bottomY, 84, 21);
    frmParent = CGRectMake(8, 37, size.width-16, sizeParent.height);
    frmLogo = CGRectMake(frmParent.size.width - 52, 13, 32, 32);
    frmContent = CGRectMake(8, 9, frmParent.size.width-16, frmParent.size.height-18);
    //CGRect frmBorder = CGRectMake(1, 1, size.width-2, bottomY + 36);
    
    if (viewParent == nil) {
        viewParent = [[UIView alloc] initWithFrame:frmParent];
        [self addSubview:viewParent];
    }
    [viewParent setFrame:frmParent];
    
    /*
    const CGFloat *coms = CGColorGetComponents(color.CGColor);
    CGFloat r = coms[0], g = coms[1], b = coms[2];
    if ((r + g + b) / 3 > 0.5)
        [self setBackgroundColor:[UIColor lightGrayColor]];
     */
    
    if (lblTitle == nil) {
        lblTitle = [[UILabel alloc] initWithFrame:frmTitle];
        [lblTitle setFont:[UIFont fontWithName:@"Lato-Medium" size:20]];
        [self addSubview:lblTitle];
    }
    [lblTitle setFrame:frmTitle];
    if (lblContent == nil) {
        lblContent = [[UILabel alloc] initWithFrame:frmContent];
        [lblContent setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [viewParent addSubview:lblContent];
    }
    [lblContent setFrame:frmContent];
#ifndef OODLES
    if (imgLogo == nil) {
        imgLogo = [[UIImageView alloc] initWithFrame:frmLogo];
        [imgLogo setContentMode:UIViewContentModeScaleAspectFit];
        [viewParent addSubview:imgLogo];
    }
    [imgLogo setFrame:frmLogo];
#endif
    if (btnSeeAll == nil) {
        btnSeeAll = [[UIButton alloc] initWithFrame:frmSeeAll];
        [[btnSeeAll titleLabel] setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [btnSeeAll setTitleColor:colorTitle forState:UIControlStateNormal];
        [btnSeeAll setTitle:@">" forState:UIControlStateNormal];
        
        [btnSeeAll addTarget:self action:@selector(showCategory:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btnSeeAll];
    }
    [btnSeeAll setFrame:frmSeeAll];
    if (btnLike == nil) {
        //NSString* clike = [msg likeCount] != 0 ? [NSString stringWithFormat:@"%d", [msg likeCount]] : @"";
#ifdef OODLES
        NSString* img = @"See-It-icon_64";
        NSString* rightText = @"See";
#else
        NSString* img = [msg liked] ? @"heart_red" : @"heart_dkgrey";
        NSString* rightText = @"like it";
#endif
        btnLike = [[UICaptionButton alloc] initWithFrame:frmLike
                                               withImage:[UIImage imageNamed:img]
                                            andRightText:rightText];
        [btnLike setSelected:[_msg liked]];
        //[btnLike setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        
        [btnLike addTarget:self action:@selector(likeMessage:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btnLike];
    }
    [btnLike setFrame:frmLike];
#ifndef OODLES
    if (btnPin == nil) {
        NSString* pinImg = [msg pinned] ? @"pin_red" : @"pin_dkgrey";
        btnPin = [[UICaptionButton alloc] initWithFrame:frmPin withImage:[UIImage imageNamed:pinImg]
                                                andRightText:@"save it"];
        //[btnPin setImage:[UIImage imageNamed:@"pinblack_btn"] forState:UIControlStateNormal];
        [btnPin addTarget:self action:@selector(pinMessage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnPin];
    }
    [btnPin setFrame:frmPin];
#endif
    if (btnSend == nil) {
#ifdef OODLES
        NSString* imgSend = @"share-it-icon_64";
        NSString* rightText2 = @"Share";
#else
        NSString* imgSend = @"TextMuseButton";
        NSString* rightText2 = @"text it";
#endif
        bool send = true;
#ifdef OODLES
        send = ![msg badge];
#endif
        if (send) {
            btnSend = [[UICaptionButton alloc] initWithFrame:frmSend
                                                   withImage:[UIImage imageNamed:imgSend]
                                                andRightText:rightText2];
            [btnSend addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btnSend];
        }
    }
    [btnSend setFrame:frmSend];
    
    [lblTitle setText:[msg category]];
    [lblTitle setTextColor:[UIColor darkGrayColor]];
    [lblContent setTextColor:[UIColor darkGrayColor]];
    //[lblTitle setTextColor:colorTitle];
    //[lblContent setTextColor:colorText];
    
    if ([[msg text] length] > 0) {
        [lblContent setHidden:NO];
        NSString* txt = [msg getFullMessage];
        [lblContent setText:txt];
    }
    else {
        [lblContent setHidden:NO];
        [lblContent setText:@""];
    }

    MessageCategory* category = [Data getCategory:[msg category]];
    if ([msg version] && [category useIcon]) {
        [imgLogo setHidden:NO];
        frmTitle.origin.x = 8; //35;
        [lblTitle setFrame:frmTitle];
        downloader = [[ImageDownloader alloc] initWithUrl:[sponsor Icon]
                                               forImgView:imgLogo
                                         chooseBackground:[NSArray arrayWithObjects:[Skin Color1],
                                                           [Skin Color2], [Skin Color3], nil]];
        [downloader load];
        //[imgLogo setAlpha:0.95];
        [viewParent bringSubviewToFront:imgLogo];
        
        //UIView* viewBorder = [[UIView alloc] initWithFrame:frmBorder];
        //[[viewBorder layer] setBorderColor:[colorTitle CGColor]];
        //[[viewBorder layer] setBorderWidth:2.0];
        //[self addSubview:viewBorder];
        //[self sendSubviewToBack:viewBorder];
    }
    else {
        [imgLogo setHidden:YES];
        frmTitle.origin.x = 8;
        [lblTitle setFrame:frmTitle];
    }
}

-(IBAction)showCategory:(id)sender {
    CurrentCategory = [_msg category];
    CurrentMessage = nil;
    [_nav performSegueWithIdentifier:@"SelectMessage" sender:_nav];
}

-(IBAction)sendMessage:(id)sender {
    CurrentCategory = [_msg category];
    CurrentMessage = _msg;

    if ([[Data getContacts] count] == 0) {
        if (sendMessage == nil)
            sendMessage = [[SendMessage alloc] init];
        [sendMessage sendMessageTo:nil from:_nav];
    }
    else
        [_nav performSegueWithIdentifier:@"SendMessage" sender:_nav];
}

-(IBAction)likeMessage:(id)sender {
#ifdef OODLES
    CurrentCategory = [_msg category];
    CurrentMessage = _msg;
    [_nav performSegueWithIdentifier:@"SelectMessage" sender:_nav];
#else
    [_msg setLiked:![_msg liked]];
    [_msg setLikeCount:[_msg likeCount] + ([_msg liked] ? 1 : -1)];
    
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlLikeNote]
                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                   timeoutInterval:30];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[[NSString stringWithFormat:@"id=%ld&app=%@&h=%d",
                       (long)[_msg msgId], AppID, ([_msg liked] ? 1 : 0)]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:nil
                                                    startImmediately:YES];

    [btnLike setSelected:[_msg liked]];
    NSString* img = [_msg liked] ? @"heart_red" : @"heart_black";
    [btnLike setImage:[UIImage imageNamed:img]];
    //[btnLike setRightCaption:[_msg likeCount] == 0 ? @"" : [NSString stringWithFormat:@"%d", [_msg likeCount]]];
#endif
}

-(IBAction)pinMessage:(id)sender {
    [_msg setPinned:![_msg pinned]];
    [Data setMessagePin:_msg withValue:[_msg pinned]];
    
    if ([_msg pinned])
        [SqlDb pinMessage:_msg];
    else
        [SqlDb unpinMessage:_msg];
    
    NSString* pinImg = [_msg pinned] ? @"pin_red" : @"pin_black";
    [btnPin setImage:[UIImage imageNamed:pinImg]];
}

-(void)setTableView:(UITableView*)tableView {
    _tableView = tableView;
}

+(CGSize) GetContentSizeForImage:(UIImage*) img inSize:(CGSize)sizeParent {
    CGFloat heightParent = 133;
    CGFloat widthParent = sizeParent.width;
    CGSize size = [img size];
    CGFloat ratio = size.height / size.width;
    if (size.height > heightParent) {
        if (size.width <= widthParent)
            heightParent = size.height;
        else {
            heightParent = ratio * widthParent;
        }
    }
    if (heightParent > (sizeParent.height / 2.5)) {
        heightParent = (sizeParent.height / 2.5);
        widthParent = (1/ratio) * heightParent;
    }
    
    return CGSizeMake(widthParent, heightParent);
}

+(CGFloat)GetCellHeightForMessage:(Message *)msg inSize:(CGSize)size {
    CGFloat height = 225.0;
    if (![msg isImgNull]) {
        UIImage* img = [UIImage imageWithData:[msg img]];
        CGSize sizeContent = [MessageTableViewCell GetContentSizeForImage:img inSize:size];
        height = 92.0 + sizeContent.height;
    }
    return height;
}

@end
