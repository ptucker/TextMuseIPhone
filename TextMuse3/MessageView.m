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

//#define BUTTONSSIDE
#define BUTTONSBOTTOM

NSString* urlFollowSponsor = @"https://www.textmuse.com/admin/following.php";
extern NSString* urlUpdateQuickNotes;
extern NSString* urlRemitBadge;

@implementation MessageView

@synthesize phones;

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
        [btnExit setImage:[UIImage imageNamed:@"arrow-collapse-left"] forState:UIControlStateNormal];
        [[btnExit titleLabel] setFont:[TextUtil GetDefaultFontForSize:20.0]];
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

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setShowBadges:NO];
    [self setIsFullScreen:NO];
    
    swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(close:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipe setDelaysTouchesBegan:YES];
    [self addGestureRecognizer:swipe];
    
    return self;
}

-(void)setTarget:(UIViewController *)vc withSelector:(SEL)sel andQuickSend:(SEL)selQuick {
    [btnText addTarget:vc action:sel forControlEvents:UIControlEventTouchUpInside];
    [btnTextContact addTarget:vc action:selQuick forControlEvents:UIControlEventTouchUpInside];
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

-(void)setHeaderForMessage:(Message*)msg inView:(UIView*)subview {
    UILabel* header = [[UILabel alloc] initWithFrame:[subview frame]];
    [header setText:[[msg sponsorName] length] > 0 ? [msg sponsorName] : [msg category]];
    [header setFont:[TextUtil GetDefaultFontForSize:24.0]];
    [header setTextColor:[UIColor darkGrayColor]];
    [subview addSubview:header];
}

-(int)getHeightForMessageDetails:(Message*) msg inFrame:(CGRect)frame {
    int margin = 48;
    int ret = [self getHeightForContacts:msg inFrame:frame] + margin;
    
    return ret;
}

-(int)getHeightForContacts:(Message*)msg inFrame:(CGRect)frame {
    int ret = 0;
    if ([msg phoneno] != nil && [[msg phoneno] length] > 0)
        ret = [self getHeightForPhoneContactForMessage:msg inFrame:frame];
    else if ([msg textno] != nil && [[msg textno] length] > 0)
        [self getHeightForTextContactForMessage:msg inFrame:frame];
    ret += [self getHeightForTextItButtonForMessage:msg inFrame:frame];
    ret += [self getHeightForTextDetailsForMessage:msg inFrame:frame];
    
    return ret;
}

-(NSString*)getPhoneContactTextForMessage:(Message*)msg {
    return [NSString stringWithFormat:@"p: %@", [msg phoneno]];
}

-(NSString*)getTextContactTextForMessage:(Message*)msg {
    return [NSString stringWithFormat:@"y: %@", [msg textno]];
}

-(NSString*)getTextItTextForMessage:(Message*)msg {
    NSString* ret = @"TEXT IT";
    if ([msg badge])
        ret = @"REMIT IT";
    else if ([msg isPrayer])
        ret = @"PRAY FOR";
    return ret;
}

-(NSString*)getTwoTierTextForMessage:(Message*)msg {
    return [msg sendcount] != 0 ? [NSString stringWithFormat:@"Text to %d: %@", [msg sendcount], [msg winnerText]] : @"";
}

-(NSString*)getThreeTierTextForMessage:(Message*)msg {
    return [msg visitcount] != 0 ? [NSString stringWithFormat:@"Visit with %d badges: %@", [msg visitcount], [msg visitWinnerText]] : @"";}

-(int)getHeightForPhoneContactForMessage:(Message*)msg inFrame:(CGRect)frame {
    /*
    NSString* pno = [self getPhoneContactTextForMessage:msg];
    return [TextUtil GetContentSizeForText:pno inSize:frame.size forFont:[self getFontForButton]].height;
     */
    return 32;
}

-(int)getHeightForTextContactForMessage:(Message*)msg inFrame:(CGRect)frame {
    NSString* tno = [self getTextContactTextForMessage:msg];
    return [TextUtil GetContentSizeForText:tno inSize:frame.size forFont:[self getFontForButton]].height;
}

-(int)getHeightForTextItButtonForMessage:(Message*)msg inFrame:(CGRect)frame {
    /*
    NSString* title = [self getTextItTextForMessage:msg];
    return [TextUtil GetContentSizeForText:title inSize:frame.size forFont:[self getFontForButton]].height;
     */
    return 32;
}

-(UIFont*)getFontForButton{
    CGFloat fontsize = [self frame].size.width < 321 ? 14 : 18;
    return [TextUtil GetBoldFontForSize:fontsize];
}

-(UIFont*)getFontForTextDetails {
    CGFloat fontsize = [self frame].size.width < 321 ? 12 : 16;
    return [TextUtil GetLightFontForSize:fontsize];
}

-(int)getHeightForTextDetailsForMessage:(Message*)msg inFrame:(CGRect)frame {
    int ret = 0;
    
    if ([msg sendcount] == 0 && [msg visitcount] == 0)
        return ret;
    
    ret += 10;
    CGFloat imgSize = (frame.size.height < 250) ? 32 : 48;
    
    if ([msg sendcount] != 0 && [msg badgeURL] != nil && [[msg badgeURL] length] > 0) {
        ret += imgSize + 8;
    }
    
    NSString* twotier = [self getTwoTierTextForMessage:msg];
    NSString* threetier = [self getThreeTierTextForMessage:msg];
    UIFont* fontDetails = [self getFontForTextDetails];
    CGSize szTwo = [TextUtil GetContentSizeForText:twotier inSize:frame.size forFont:fontDetails];
    CGSize szThree = [TextUtil GetContentSizeForText:threetier inSize:frame.size forFont:fontDetails];
    ret += szTwo.height + 8 + szThree.height + 8;

    return ret;
}

-(void)setDetailsForMessage:(Message *)msg inView:(UIView *)subview {
    //add these from the bottom up.
    bottom = [subview frame].size.height;
    [self setTextItButtonForMessage:msg inView:subview];
    [self setSeeItButtonForMessage:msg inView:subview];
    [self setFollowButtonForMessage:msg inView:subview];
    bottom -= ([self getHeightForTextItButtonForMessage:msg inFrame:[subview frame]] + 8);
    
    [self setContactsForMessage:msg inView:subview];
    bottom -= ([self getHeightForPhoneContactForMessage:msg inFrame:[subview frame]] + 8);

    [self setDetailsTextForMessage:msg inView:subview];
}

-(void)setContactsForMessage:(Message *)msg inView:(UIView *)subview {
    if ([msg phoneno] != nil && [[msg phoneno] length] > 0)
        [self setPhoneContactForMessage:msg inView:subview];
    if ([msg address] != nil && [[msg address] length] > 0)
        [self setMapForMessage:msg inView:subview];
    if ([msg textno] != nil && [[msg textno] length] > 0)
        [self setTextContactForMessage:msg inView:subview];
}

-(void)setPhoneContactForMessage:(Message *)msg inView:(UIView *)subview {
    CGRect frmView = [subview frame];
    //NSString* pno = [self getPhoneContactTextForMessage:msg];
    CGFloat height = [self getHeightForPhoneContactForMessage:msg inFrame:frmView];
    CGFloat w = height;
    CGFloat x = (3*(frmView.size.width/4)) - (w/2);
    CGRect frmButton = CGRectMake(x, bottom - height, w, height);
    UIButton* btnPhone = [[UIButton alloc] initWithFrame:frmButton];
    //[btnPhone setTitle:pno forState:UIControlStateNormal];
    [btnPhone setImage:[UIImage imageNamed:@"phone-outgoing"] forState:UIControlStateNormal];
    //[self setPropsForButton:btnPhone withColor:[SkinInfo Color1TextMuse]];
    //[self tintImageForButton:btnPhone withColor:[SkinInfo Color1TextMuse] inFrame:frmButton];
    [subview addSubview:btnPhone];

    [btnPhone addTarget:self action:@selector(sendContactPhone:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setMapForMessage:(Message *)msg inView:(UIView *)subview {
    CGRect frmView = [subview frame];
    //NSString* pno = [self getPhoneContactTextForMessage:msg];
    CGFloat height = [self getHeightForPhoneContactForMessage:msg inFrame:frmView];
    CGFloat w = height;
    CGFloat x = (frmView.size.width/2) - (w/2);
    CGRect frmButton = CGRectMake(x, bottom - height, w, height);
    UIButton* btnMap = [[UIButton alloc] initWithFrame:frmButton];
    //[btnMap setTitle:pno forState:UIControlStateNormal];
    [btnMap setImage:[UIImage imageNamed:@"map-marker"] forState:UIControlStateNormal];
    [self setPropsForButton:btnMap withColor:[SkinInfo Color1TextMuse]];
    //[self tintImageForButton:btnMap withColor:[SkinInfo Color1TextMuse] inFrame:frmButton];
    [subview addSubview:btnMap];
    
    [btnMap addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setTextContactForMessage:(Message *)msg inView:(UIView *)subview {
    CGRect frmView = [subview frame];
    //NSString* tno = [self getTextContactTextForMessage:msg];
    CGFloat height = [self getHeightForPhoneContactForMessage:msg inFrame:frmView];
    CGFloat w = height;
    CGFloat x = (frmView.size.width/4) - (w/2);
    CGRect frmButton = CGRectMake(x, bottom - height, w, height);
    btnTextContact = [[UIButton alloc] initWithFrame:frmButton];
    //[btnTextContact setTitle:tno forState:UIControlStateNormal];
    [btnText setImage:[UIImage imageNamed:@"message-test"] forState:UIControlStateNormal];
    //[self setPropsForButton:btnTextContact withColor:[SkinInfo Color1TextMuse]];
    //[self tintImageForButton:btnTextContact withColor:[SkinInfo Color1TextMuse] inFrame:frmButton];
    [subview addSubview:btnTextContact];
}

-(void)setTextItButtonForMessage:(Message*)msg inView:(UIView *)subview {
    CGRect frmView = [subview frame];
    if (btnText == nil) {
        CGFloat buttonWidth = frmView.size.width / 4;
        CGFloat height = [self getHeightForTextItButtonForMessage:msg inFrame:frmView];
        CGRect frmButton = CGRectMake(10, bottom - height, buttonWidth, height);

        NSString* title = [self getTextItTextForMessage:msg];
        btnText = [[UIButton alloc] initWithFrame:frmButton];
        [btnText setTitle:title forState:UIControlStateNormal];
        [self setPropsForButton:btnText withColor:[SkinInfo Color1TextMuse]];
        [subview addSubview:btnText];
    }
}

-(void)setSeeItButtonForMessage:(Message*)msg inView:(UIView *)subview {
    CGRect frmView = [subview frame];
#ifndef OODLES
    if (btnDetails == nil) {
        CGFloat buttonWidth = frmView.size.width / 4;
        CGFloat x = (frmView.size.width / 2) - (buttonWidth / 2);
        CGRect frmButton = CGRectMake(x, bottom - 32, buttonWidth, 32);

        btnDetails = [[UIButton alloc] initWithFrame:frmButton];
        [btnDetails setTitle:@"WEBSITE" forState:UIControlStateNormal];
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
    CGRect frmView = [subview frame];
#ifndef OODLES
    if (btnFollow == nil && [[msg sponsorName] length] > 0) {
        NSString* followText = [NSString stringWithFormat:@"%@OLLOW", [msg following] ? @"UNF" : @"F"];
        CGFloat buttonWidth = frmView.size.width / 4;
        CGRect frmButton = CGRectMake(frmView.size.width - 10 - buttonWidth, bottom-32, buttonWidth, 32);

        btnFollow = [[UIButton alloc] initWithFrame:frmButton];
        [self setPropsForButton:btnFollow withColor:[SkinInfo Color3TextMuse]];
        [btnFollow setTitle:followText forState:UIControlStateNormal];
        [btnFollow addTarget:self action:@selector(followSponsor:)
            forControlEvents:UIControlEventTouchUpInside];
        [subview addSubview:btnFollow];
    }
#endif
}

-(void) setPropsForButton:(UIButton*)btn withColor:(NSString*)color {
    UIFont* fnt = [self getFontForButton];
    [[btn titleLabel] setFont:fnt];
    [[btn titleLabel] setNumberOfLines:1];
    [[btn titleLabel] sizeToFit];
    
    [btn setTitleColor:[SkinInfo createColor:color] forState:UIControlStateNormal];

    /*
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    UIColor* bkg = [SkinInfo createColor:color];
    [btn setBackgroundImage:[ImageUtil imageFromColor:bkg] forState:UIControlStateNormal];
    [[btn layer] setCornerRadius:10];
    [[btn layer] setMasksToBounds:YES];
     */
}

-(void)tintImageForButton:(UIButton*)btn withColor:(NSString*)color inFrame:(CGRect)frame {
    UIView* cover = [[UIView alloc] initWithFrame:frame];
   
    [cover setBackgroundColor:[SkinInfo createColor:color]];
    [[cover layer] setOpacity:0.75];
    
    UIImageView* imageView = [btn imageView];
    imageView.image = [[[btn imageView] image] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    
    [imageView addSubview:cover];
}

-(void)setDetailsTextForMessage:(Message*)msg inView:(UIView*)subview {
    if ([msg sendcount] == 0 && [msg visitcount] == 0)
        return;
    
    NSString* twotier = [self getTwoTierTextForMessage:msg];
    NSString* threetier = [self getThreeTierTextForMessage:msg];
    UIFont* fontDetails = [self getFontForTextDetails];
    
    CGSize frameText = CGSizeMake([subview frame].size.width - 20, [subview frame].size.height);
    CGSize szTwo = [TextUtil GetContentSizeForText:twotier inSize:frameText forFont:fontDetails];
    CGSize szThree = [TextUtil GetContentSizeForText:threetier inSize:frameText forFont:fontDetails];
    CGFloat lblx2 = ([subview frame].size.width - szTwo.width) / 2;
    CGFloat lblx3 = ([subview frame].size.width - szThree.width) / 2;
    CGRect frmLblx3 = CGRectMake(lblx3, bottom - szThree.height, szThree.width, szThree.height);
    bottom -= (szThree.height + 8);
    CGRect frmLblx2 = CGRectMake(lblx2, bottom - szTwo.height, szTwo.width, szTwo.height);
    bottom -= (szTwo.height + 8);

    CGFloat imgSize = ([subview frame].size.height < 250) ? 32 : 48;
    CGFloat topImage = bottom - imgSize;
    int start = ([subview frame].size.width / 2) - 83;

    if ([msg sendcount] != 0 && [msg badgeURL] != nil && [[msg badgeURL] length] > 0) {
        for (int i=0; i<3; i++) {
            UIImageView* imgBadge = [[UIImageView alloc] initWithFrame:CGRectMake(start + (i*60), topImage, imgSize, imgSize)];
            [subview addSubview:imgBadge];
            ImageDownloader* loader = [[ImageDownloader alloc] initWithUrl:[msg badgeURL]
                                                                forImgView:imgBadge];
            [loader load];
        }
    }

    UILabel* lblTwo = [[UILabel alloc] initWithFrame:frmLblx2];
    [lblTwo setText:twotier];
    [lblTwo setNumberOfLines:0];
    [lblTwo setFont:fontDetails];
    [lblTwo setTextColor:[UIColor blackColor]];
    [lblTwo setTextAlignment:NSTextAlignmentCenter];
    [subview addSubview:lblTwo];

    UILabel* lblThree = [[UILabel alloc] initWithFrame:frmLblx3];
    [lblThree setText:threetier];
    [lblThree setNumberOfLines:0];
    [lblThree setFont:fontDetails];
    [lblThree setTextColor:[UIColor blackColor]];
    [lblThree setTextAlignment:NSTextAlignmentCenter];
    [subview addSubview:lblThree];
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
    
    NSString* followText = [NSString stringWithFormat:@"%@OLLOW%@", [message following] ? @"UNF" : @"F",
                            [message sponsorLogo] == nil ?
                            [NSString stringWithFormat:@"\n%@", [message sponsorName]] : @""];
    if ([sender isKindOfClass:[UICaptionButton class]])
        [(UICaptionButton*)sender setCaption:followText];
    else {
        [(UIButton*)sender setTitle:followText forState:UIControlStateNormal];
        [(UIButton*)sender sizeToFit];
    }

    
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
    IMP imp = [[self mvcSendMessage] methodForSelector:selector];
    void (*func)(id, SEL, id) = (void *)imp;
    func([self mvcSendMessage], selector, sender);
#endif
}

-(IBAction)likeMessage:(id)sender {
    [message setLiked:![message liked]];
    [message setLikeCount:[message likeCount] + ([message liked] ? 1 : -1)];
    
    NSMutableURLRequest* req = [NSMutableURLRequest
                                requestWithURL:[NSURL URLWithString:@"https://www.textmuse.com/admin/notelike.php"]
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

/*
-(IBAction)sendMessage:(id)sender {
    if ([message badge]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Remit badge?"
                                                        message:@"Are you sure you want to remit this badge?"
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Yes Button", nil)
                                              otherButtonTitles:NSLocalizedString(@"No Button", nil), nil];
        [alert show];
    }
    else {
        CurrentMessage = message;
        if ([[Data getContacts] count] == 0)
            [Data initContacts];

        if ([[Data getContacts] count] == 0) {
            SendMessage* sendMessage = [[SendMessage alloc] init];
            [sendMessage sendMessageTo:nil from:[self vcSendMessage]];
        }
        else
            [[self vcSendMessage] performSegueWithIdentifier:@"SendMessage" sender:self];
    }
}
*/

/*
-(IBAction)sendContactMessage:(id)sender {
    CurrentMessage = [[Message alloc] init];
    [CurrentMessage setMsgId:0];
    [CurrentMessage setText:@"message"];
    NSArray* phones = [[NSArray alloc] initWithObjects:[message textno], nil];
    SendMessage* sendMessage = [[SendMessage alloc] init];
    
    [sendMessage sendMessageTo:phones from:[self vcSendMessage]];
}
*/

-(IBAction)sendContactPhone:(id)sender {
    NSString *phoneNumber = [[message phoneno] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt:" stringByAppendingString:phoneNumber]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel:" stringByAppendingString:phoneNumber]];

    NSURL* url = [NSURL URLWithString:urlUpdateQuickNotes];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                   timeoutInterval:30];
    [req setHTTPMethod:@"POST"];
    NSString* post = [NSString stringWithFormat:@"id=%d&app=%@&cnt=%d&phone=1",
                      [message msgId], AppID, 1];
    [req setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:nil
                                                    startImmediately:YES];

    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [UIApplication.sharedApplication openURL:phoneUrl];
    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl];
    }
}

-(IBAction)showMap:(id)sender {
    [message showMap:sender];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [SqlDb flagMessage:message];
        [Data reloadData];
        
        NSMutableURLRequest* req = nil;
        req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlRemitBadge]
                                      cachePolicy:NSURLRequestReloadIgnoringCacheData
                                  timeoutInterval:30];
        [req setHTTPBody:[[NSString stringWithFormat:@"app=%@&game=%ld", AppID, -1*(long)[message msgId]]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [req setHTTPMethod:@"POST"];
        NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                                delegate:nil
                                                        startImmediately:YES];
        
        [self close:nil];
    }
}

-(IBAction)close:(id)sender {
    CGRect frmEnd = [self frame];
    /*
    //Slide up
    frmEnd.origin.y = -frmEnd.size.height;
    */
    //Slide left
    frmEnd.origin.x = -frmEnd.size.width;
    [self removeGestureRecognizer:swipe];
    
    [UIView animateWithDuration:0.5
                     animations: ^{ [self setFrame: frmEnd]; }
                     completion: ^(BOOL finished) {[self removeFromSuperview];}];
}

@end
