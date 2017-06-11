//
//  MessageView.m
//  TextMuse2
//
//  Created by Peter Tucker on 4/19/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "MessageView.h"
#import "TextMessageView.h"
#import "ImageMessageView.h"
#import "ImageUtil.h"
#import "TextUtil.h"
#import "GlobalState.h"
#import "Settings.h"
#import "FLAnimatedImage.h"
#import "UICaptionButton.h"
#import "AppDelegate.h"

NSString* urlFollowSponsor = @"http://www.textmuse.com/admin/following.php";

@implementation MessageView

UIImage* bubble1 = nil;
UIImage* bubble2 = nil;
UIImage* bubble3 = nil;
UIImage* leftQuote = nil;
UIImage* rightQuote = nil;
UIImage* likeRed = nil;
UIImage* likeGrey = nil;
UIImage* pinRed = nil;
UIImage* pinGrey = nil;
UIImage* openInNew = nil;

+(MessageView*)setupViewForMessage:(Message*)msg
                           inFrame:(CGRect)frame
                        withBadges:(bool) b
                        fullScreen:(bool)f
                         withColor:(UIColor*)color
                             index:(long)i {
    MessageView* mv = ([msg img] == nil) ? [[TextMessageView alloc] initWithFrame:frame] :[[ImageMessageView alloc] initWithFrame:frame];
    [mv setShowBadges:b];
    [mv setIsFullScreen:f];
    [mv setupViewForMessage:msg inFrame:frame withColor:color index:i];
    
    if ([mv isFullScreen]) {
        [mv setBackgroundColor:[UIColor whiteColor]];
        
        CGRect frmExit = CGRectMake(frame.size.width-32, 32, 32, 32);
        UIButton* btnExit = [[UIButton alloc] initWithFrame:frmExit];
        [btnExit setBackgroundColor:[UIColor lightGrayColor]];
        [btnExit setTitle:@"X" forState:UIControlStateNormal];
        [[btnExit titleLabel] setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
        [btnExit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnExit addTarget:mv action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        [mv addSubview:btnExit];
    }
    
    return mv;
}

+(MessageView*)setupViewForMessage:(Message*)msg
                        withBadges:(bool) b
                        fullScreen:(bool)f
                           inFrame:(CGRect)frame {
    return [MessageView setupViewForMessage:msg
                                    inFrame:frame
                                 withBadges:b
                                 fullScreen:f
                                  withColor:[UIColor lightGrayColor]
                                      index:-1];
}

-(id)init {
    [self setShowBadges:NO];
    [self setIsFullScreen:NO];
    
    return self;
}

-(void)setupViewForMessage:(Message *)msg inFrame:(CGRect)frame withColor:(UIColor*)color index:(long)i {
    @throw [NSException exceptionWithName:@"AbstractMethod"
                                   reason:@"This base class doesn't implement this method"
                                 userInfo:nil];
}

/*
-(void)setLikeButtonForMessage:(Message*)msg inFrame:(CGRect)frmLike {
    //NSString* likeText = [msg likeCount] > 0 ? [NSString stringWithFormat:@"%d", [msg likeCount]] : @"";
    if (btnLike == nil) {
#ifdef OODLES
        btnLike = [[UICaptionButton alloc] initWithFrame:frmLike
                                               withImage:[UIImage imageNamed:@"See-It-icon_64"]
                                            andRightText:@"See"];
        [btnLike addTarget:self action:@selector(messageFollow:)
          forControlEvents:UIControlEventTouchUpInside];
#else
        UIImage* like = [msg liked] ? likeRed : likeGrey;
        btnLike = [[UICaptionButton alloc] initWithFrame:frmLike
                                               withImage:like
                                                 andText:@"like it"];
        [btnLike addTarget:self action:@selector(likeMessage:) forControlEvents:UIControlEventTouchUpInside];
#endif
        [btnLike setCaptionColor:[UIColor darkGrayColor]];
        [btnLike setFrame:frmLike];
#ifdef OODLES
        if (![msg badge])
            [self addSubview:btnLike];
#else
        [self addSubview:btnLike];
#endif
    }
}
*/

/*
-(void)setPinButtonForMessage:(Message*)msg inFrame:(CGRect)frmPin {
#ifdef OODLES
    if (![msg badge]) {
        [self addSubview:btnPin];
        [btnPin setFrame:frmPin];
        [btnPin addTarget:self action:@selector(pinMessage:)
         forControlEvents:UIControlEventTouchUpInside];
    }
#else
    [self addSubview:btnPin];
    [btnPin setFrame:frmPin];
    [btnPin addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
#endif
}
*/

-(void)setDetailsForMessage:(Message *)msg inView:(UIView *)subview {
    [self setTextItButtonForMessage:msg inView:subview];
    [self setSeeItButtonForMessage:msg inView:subview];
    [self setFollowButtonForMessage:msg inView:subview];
    
    [self setDetailsTextForMessage:msg inView:subview];
}

-(void)setTextItButtonForMessage:(Message*)msg inView:(UIView *)subview {
    if (btnText == nil) {
        CGRect frmButton = CGRectMake([subview frame].size.width - 120, 10, 112, 32);
        btnText = [[UIButton alloc] initWithFrame:frmButton];
        [btnText setTitle:@"Text It" forState:UIControlStateNormal];
        [self setPropsForButton:btnText withColor:[SkinInfo Color1TextMuse]];
        [subview addSubview:btnText];
    }
    
    [btnText addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setSeeItButtonForMessage:(Message*)msg inView:(UIView *)subview {
#ifndef OODLES
    if (btnDetails == nil) {
        CGRect frmButton = CGRectMake([subview frame].size.width - 120, 50, 112, 32);
        btnDetails = [[UIButton alloc] initWithFrame:frmButton];
        [btnDetails setTitle:@"See It" forState:UIControlStateNormal];
        [self setPropsForButton:btnDetails withColor:[SkinInfo Color2TextMuse]];
        [btnDetails setHidden:[msg url] == nil || [[msg url] length] == 0];
        [subview addSubview:btnDetails];
    }
    
    [btnDetails setHidden:[msg url] == nil];
    
    [btnDetails addTarget:self action:@selector(messageFollow:)
         forControlEvents:UIControlEventTouchUpInside];
#endif
}

-(void)setFollowButtonForMessage:(Message*)msg inView:(UIView *)subview {
#ifndef OODLES
    if (btnFollow == nil && [[msg sponsorName] length] > 0) {
        NSString* followText = [NSString stringWithFormat:@"%@ollow%@", [msg following] ? @"Unf" : @"F",
                                [NSString stringWithFormat:@"\n%@", [msg sponsorName]]];
        CGRect frmButton = CGRectMake([subview frame].size.width - 120, 90, 112, 64);
        btnFollow = [[UIButton alloc] initWithFrame:frmButton];
        [self setPropsForButton:btnFollow withColor:[SkinInfo Color3TextMuse]];
        [[btnFollow titleLabel] setNumberOfLines:2];
        [btnFollow setTitle:followText forState:UIControlStateNormal];
        [btnFollow addTarget:self action:@selector(followSponsor:)
            forControlEvents:UIControlEventTouchUpInside];
        [subview addSubview:btnFollow];
    }
#endif
}

-(void) setPropsForButton:(UIButton*)btn withColor:(NSString*)color {
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[btn titleLabel] setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
    [[btn titleLabel] setNumberOfLines:1];

    UIColor* bkg = [SkinInfo createColor:color];
    [btn setBackgroundImage:[ImageUtil imageFromColor:bkg] forState:UIControlStateNormal];
    [[btn layer] setCornerRadius:10];
    [[btn layer] setMasksToBounds:YES];
}

-(void)setDetailsTextForMessage:(Message*)msg inView:(UIView*)subview {
    NSString* twotier = [msg sendcount] != 0 ?
        [NSString stringWithFormat:@"Send to %d friends: %@", [msg sendcount], [msg winnerText]] : @"";
    NSString* threetier = [msg visitcount] != 0 ?
        [NSString stringWithFormat:@"Visit with %d friends who also have the badge to get an even better deal", [msg visitcount]] : @"";
    
    UIFont* fontDetails = [UIFont fontWithName:@"Lato-Light" size:18];
    
    CGSize frameText = CGSizeMake([subview frame].size.width - 100, [subview frame].size.height);
    CGSize szTwo = [TextUtil GetContentSizeForText:twotier inSize:frameText forFont:fontDetails];
    CGSize szThree = [TextUtil GetContentSizeForText:threetier inSize:frameText forFont:fontDetails];
    
    UILabel* lblTwo = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, szTwo.width, szTwo.height)];
    [lblTwo setText:twotier];
    [lblTwo setNumberOfLines:0];
    [lblTwo setFont:fontDetails];
    [lblTwo setTextColor:[UIColor blackColor]];
    [subview addSubview:lblTwo];

    UILabel* lblThree = [[UILabel alloc] initWithFrame:CGRectMake(10, szTwo.height + 10,
                                                                  szThree.width, szThree.height)];
    [lblThree setText:threetier];
    [lblThree setNumberOfLines:0];
    [lblThree setFont:fontDetails];
    [lblThree setTextColor:[UIColor blackColor]];
    [subview addSubview:lblThree];
    
    if ([msg badgeURL] != nil && [[msg badgeURL] length] > 0) {
        UIImageView* imgBadge = [[UIImageView alloc] initWithFrame:CGRectMake([subview frame].size.width - 120, 160, 48, 48)];
        [subview addSubview:imgBadge];
        ImageDownloader* loader = [[ImageDownloader alloc] initWithUrl:[msg badgeURL]
                                                            forImgView:imgBadge];
        [loader load];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Add your message..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Add your message...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    else
        [message updateText:textView];
    [textView resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
                                               replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    else
        [message updateText:textView];

    return YES;
}

-(IBAction)messageFollow:(id)sender{
    [message follow:sender];
}

-(IBAction)followSponsor:(id)sender {
    [message setFollowing:![message following]];
    NSString* url = [NSString stringWithFormat:@"%@?app=%@&sponsor=%@&follow=%@",
                     urlFollowSponsor, AppID, [message sponsorID], ([message following] ? @"1" : @"0")];

    NSMutableURLRequest* req = [NSMutableURLRequest
                                requestWithURL:[NSURL URLWithString:url]
                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                timeoutInterval:30];
    
    NSString* followText = [NSString stringWithFormat:@"%@ollow%@", [message following] ? @"Unf" : @"F",
                            [message sponsorLogo] == nil ?
                            [NSString stringWithFormat:@"\n%@", [message sponsorName]] : @""];
    if ([sender isKindOfClass:[UICaptionButton class]])
        [(UICaptionButton*)sender setCaption:followText];
    else
        [(UIButton*)sender setTitle:followText forState:UIControlStateNormal];

    
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:nil
                                                    startImmediately:YES];

    if ([message following])
        [SponsorFollows addObject:[NSString stringWithFormat:@"spon%@", [message sponsorID]]];
    else
        [SponsorFollows removeObject:[NSString stringWithFormat:@"spon%@", [message sponsorID]]];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate registerRemoteNotificationWithAzure];
}

-(IBAction)pinMessage:(id)sender {
#ifndef OODLES
    [message setPinned:![message pinned]];
    [Data setMessagePin:message withValue:[message pinned]];
    
    if ([message pinned])
        [SqlDb pinMessage:message];
    else
        [SqlDb unpinMessage:message];
    
    //[btnPin setImage:([message pinned] ? pinRed : pinGrey)];
#else
    SEL selector = [self selSendMessage];
    IMP imp = [[self objSendMessage] methodForSelector:selector];
    void (*func)(id, SEL, id) = (void *)imp;
    func([self objSendMessage], selector, sender);
#endif
}

-(IBAction)likeMessage:(id)sender {
    [message setLiked:![message liked]];
    [message setLikeCount:[message likeCount] + ([message liked] ? 1 : -1)];
    
    NSMutableURLRequest* req = [NSMutableURLRequest
                                requestWithURL:[NSURL URLWithString:@"http://www.textmuse.com/admin/notelike.php"]
                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                timeoutInterval:30];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[[NSString stringWithFormat:@"id=%ld&app=%@&h=%d",
                       (long)[message msgId], AppID, ([message liked] ? 1 : 0)]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:nil
                                                    startImmediately:YES];
    
    //[btnLike setSelected:[message liked]];
    //[btnLike setImage:([message liked] ? likeRed : likeGrey)];
    //[btnLike setRightCaption:[message likeCount] == 0 ? @"" : [NSString stringWithFormat:@"%d", [message likeCount]]];
}

-(IBAction)sendMessage:(id)sender {
    CurrentMessage = message;
    
    if ([[Data getContacts] count] == 0) {
        SendMessage* sendMessage = [[SendMessage alloc] init];
        [sendMessage sendMessageTo:nil from:[self objSendMessage]];
    }
    else
        [[self objSendMessage] performSegueWithIdentifier:@"SendMessage" sender:self];
}

-(IBAction)close:(id)sender {
    CGRect frmEnd = [self frame];
    frmEnd.origin.y = -frmEnd.size.height;
    
    [UIView animateWithDuration:0.5
                     animations: ^{ [self setFrame: frmEnd]; }
                     completion: ^(BOOL finished) {[self removeFromSuperview];}];
}

@end
