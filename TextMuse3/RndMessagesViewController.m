//
//  RndMessagesViewController.m
//  TextMuse
//
//  Created by Peter Tucker on 12/26/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import "RndMessagesViewController.h"
#import "WalkthroughViewController.h"
#import "GuidedTourStepView.h"
#import "ImageMessageTableViewCell.h"
#import "TextMessageTableViewCell.h"
#import "Settings2ViewController.h"
#import "MessageCategory.h"
#import "Message.h"
#import "TextUtil.h"
#import "ImageDownloader.h"
#import "Settings.h"
#import "ChooseSkinView.h"
#import "UICheckButton.h"

NSArray* colors;
NSArray* colorsText;
NSArray* colorsTitle;

NSString* btnAddEvent = @"calendar-plus";
NSString* btnAddPrayer = @"prayer-icon";

const int maxRecentIDs = 10;
NSString* urlRemitBadge = @"https://www.textmuse.com/admin/remitbadge.php";
const NSString* allFilter = @"All";

@interface RndMessagesViewController ()

@end

@implementation RndMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self defaultSkin];
    
    int messagesHeight = [[self view] frame].size.height;
    [[self navigationItem] setTitle:@""];
    UIView* viewTitle = [[UIView alloc] init];
    UIImageView* imgTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-02-color_32"]];
    CGRect rctImage = CGRectMake(0,0,32,32);
    [imgTitle setFrame:rctImage];
    [imgTitle setContentMode:UIViewContentModeScaleAspectFit];
    [viewTitle addSubview:imgTitle];
    UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 75, 44)];
    [lblTitle setFont:[TextUtil GetDefaultFontForSize:24.0]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:@"TextMuse"];
    [lblTitle sizeToFit];
    [viewTitle addSubview:lblTitle];
    CGRect frmNavBar = [[[self navigationController] navigationBar] frame];
    [viewTitle sizeToFit];
    CGFloat widthTitle = 32 + [lblTitle frame].size.width;
    [viewTitle setFrame:CGRectMake(frmNavBar.size.width/2 - widthTitle/2, 6, widthTitle, 38)];
    [[self navigationItem] setTitleView:viewTitle];

#ifdef HUMANIX
    [[self navigationItem] setTitle:@"Hire Me Northwest"];
#endif
#ifdef YOUTHREACH
    [[self navigationItem] setTitle:@"YouthREACH"];
#endif
#ifdef OODLES
    [[self navigationItem] setTitle:@"Oodles"];
    [bottomMenu setHidden:YES];
    messagesHeight += 40;
#endif
#ifdef NRCC
    [[self navigationItem] setTitle:@"NRCC"];
    [bottomMenu setHidden:YES];
    messagesHeight += 40;
#endif
    
    categoryFilter = allFilter;
    
    CGFloat scrollerHeight = 30;
    CGFloat scrollerTop = [[self navigationController] navigationBar].frame.origin.y +
    [[self navigationController] navigationBar].frame.size.height;
    CGRect rctButton = CGRectMake(0, scrollerTop, [[self view] frame].size.width, scrollerHeight);
    scrollerCategories = [[UIScrollView alloc] initWithFrame:rctButton];
    [scrollerCategories setBackgroundColor:[[[self navigationController] navigationBar] backgroundColor]];
    [[self view] addSubview:scrollerCategories];
    
    messagesHeight -= (scrollerHeight + scrollerTop);
    CGRect frmMessages = CGRectMake(0, scrollerTop + scrollerHeight,
                                    [[self view] frame].size.width, messagesHeight);
    messages = [[UITableView alloc] initWithFrame:frmMessages];
    [[self view] addSubview:messages];
    showPinned = false;
    showEvents = false;
    
    if (colors == nil)
        [self setColors];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [messages addSubview:refreshControl];
    
    sendMessage = [[SendMessage alloc] init];

    [self setupToolbarButton:btnAddEvent];
    
    [[self navigationController] setDelegate:self];
    if ([colorsText count] > 0) {
        UIColor* colorTint = [colorsText objectAtIndex:0];
        //UIColor* colorBkgd = [colors objectAtIndex:2];
        [[[self navigationController] navigationBar] setTintColor:colorTint];
        //[[[self navigationController] navigationBar] setBarTintColor:colorBkgd];
        [[[self navigationController] navigationBar] setBarTintColor:[UIColor blackColor]];
    }
    
#ifdef HUMANIX
    ShowIntro = NO;
#endif
#ifdef YOUTHREACH
    ShowIntro = NO;
#endif
#ifdef NRCC
    ShowIntro = NO;
#endif
    
    if (ShowIntro) {
        if (Tour == nil)
            Tour = [[GuidedTour alloc] init];
        
        [Settings SaveSetting:SettingShowIntro withValue:@"0"];
        
        [self showChooseSkin];
    }
    
    [Data addListener:self];
    
    [messages setDelegate:self];
    [messages setDataSource:self];
    
    [messages setBackgroundColor:[UIColor whiteColor]];
    
    UIImage* o = [UIImage imageNamed:@"gear"];
    UIImage *scaledO = [UIImage imageWithCGImage:[o CGImage]
                                           scale:73.0/30
                                     orientation:(o.imageOrientation)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:scaledO
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(settings:)];
    [[self navigationItem] setLeftBarButtonItem:settingsButton];
    
    [[btnHome imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[btnBadges imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[btnGroup imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [btnBadges setTitle:@"badges" forState:UIControlStateNormal];
    [btnBadges setTitle:allFilter forState:UIControlStateSelected];
    
    contactStore = [[CNContactStore alloc] init];
    
#ifndef UNIVERSITY
    [btnBadges setHidden:YES];
#endif
}

-(void)setupToolbarButton:(NSString*)buttonIcon {
#ifdef UNIVERSITY
    UIImage* imgEvent = [UIImage imageNamed:buttonIcon];
    if (imgEvent == nil)
        imgEvent = [UIImage imageNamed:btnAddEvent];
    UIImage *scaledEvent = [UIImage imageWithCGImage:[imgEvent CGImage]
                                               scale:48.0/30
                                         orientation:(imgEvent.imageOrientation)];
    UIBarButtonItem *eventButton = [[UIBarButtonItem alloc] initWithImage:scaledEvent
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(addEvent:)];
    [eventButton setTag:([buttonIcon isEqualToString:btnAddPrayer] ? AddPrayer : AddEvent)];
    [[self navigationItem] setRightBarButtonItem: eventButton];
#endif
}

-(void)defaultSkin {
#ifdef HUMANIX
    Skin = [[SkinInfo alloc] init];
    
    [Skin setSkinID:82];
    [Skin setSkinName:@"HireMeNW"];
    [Skin setMasterName:@"HireMeNW"];
    [Skin setMasterBadgeURL:@""];
    [Skin setColor1:@"8dc73f"];
    [Skin setColor2:@"ffffff"];
    [Skin setColor3:@"231f20"];
    [Skin setHomeURL:@"http://www.humanix.com"];
    [Skin setLaunchImageURL:[[NSMutableArray alloc] init]];
    [Skin setMainWindowTitle:@"Hire Me NW"];
    [Skin setIconButtonURL:@""];
    
    [Settings SaveSkinData];
    
    [self updateSkin];
#endif
#ifdef YOUTHREACH
    Skin = [[SkinInfo alloc] init];
    
    [Skin setSkinID:171];
    [Skin setSkinName:@"Categories"];
    [Skin setMasterName:@"YouthREACH"];
    [Skin setMasterBadgeURL:@""];
    [Skin setColor1:@"000000"];
    [Skin setColor2:@"be1009"];
    [Skin setColor3:@"00009a"];
    [Skin setHomeURL:@"http://youthreachspokane.weebly.com/"];
    [Skin setLaunchImageURL:[[NSMutableArray alloc] init]];
    [Skin setMainWindowTitle:@"YouthREACH"];
    [Skin setIconButtonURL:@""];
    
    [Settings SaveSkinData];
    
    [self updateSkin];
#endif
#ifdef OODLES
    Skin = [[SkinInfo alloc] init];
    
    [Skin setSkinID:91];
    [Skin setSkinName:@"Oodles"];
    [Skin setMasterName:@"Oodles"];
    [Skin setMasterBadgeURL:@""];
    [Skin setColor1:@"73bedc"];
    [Skin setColor2:@"000000"];
    [Skin setColor3:@"ffffff"];
    [Skin setHomeURL:@"https://www.textmuse.com"];
    [Skin setLaunchImageURL:[[NSMutableArray alloc] init]];
    [Skin setMainWindowTitle:@"Oodles"];
    [Skin setIconButtonURL:@""];
    
    [Settings SaveSkinData];
    
    [self updateSkin];
#endif
#ifdef NRCC
    Skin = [[SkinInfo alloc] init];
    
    [Skin setSkinID:115];
    [Skin setSkinName:@"NRCC"];
    [Skin setMasterName:@"NRCC"];
    [Skin setMasterBadgeURL:@""];
    [Skin setColor1:@"eb181f"];
    [Skin setColor2:@"2b388a"];
    [Skin setColor3:@"ffffff"];
    [Skin setHomeURL:@"https://www.textmuse.com"];
    [Skin setLaunchImageURL:[[NSMutableArray alloc] init]];
    [Skin setMainWindowTitle:@"NRCC"];
    [Skin setIconButtonURL:@""];
    
    [Settings SaveSkinData];
    
    [self updateSkin];
#endif
}

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated {
    if (viewController == self) {
        segueSettings ? [Data reloadData] : [messages reloadData];
        segueSettings = NO;
    }
    else if ([viewController isKindOfClass:[Settings2ViewController class]])
        segueSettings = YES;

    [self setupCategoryButton];
}

-(void)setColors {
    colorsText = [NSArray arrayWithObjects:[UIColor blackColor],
                  [UIColor blackColor], [UIColor blackColor],
                  nil];

    if (Skin != nil) {
        colors = [NSArray arrayWithObjects:[Skin createColor1], [Skin createColor2], [Skin createColor3], nil];
        colorsText = [NSArray arrayWithObjects:[Skin createTextColor1],
                      [Skin createTextColor2], [Skin createTextColor3], nil];
        colorsTitle = [NSArray arrayWithArray:colors];
    }
    
    if (colors == nil)
        //Green, Orange, Blue
        colors = [NSArray arrayWithObjects: [SkinInfo createColor:[SkinInfo Color1TextMuse]],
                  [SkinInfo createColor:[SkinInfo Color2TextMuse]],
                  [SkinInfo createColor:[SkinInfo Color3TextMuse]],
                  nil];
    if (colorsTitle == nil)
        colorsTitle = [NSArray arrayWithObjects:[colors objectAtIndex:0], [colors objectAtIndex:1],
                       [colors objectAtIndex:2], nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /*
    //Show splash screen for 2 seconds
#ifdef UNIVERSITY
    if (splash == nil) {
        if (Skin != nil) {
            [self showSkinSplash:[[self view] frame]];
        }
        else {
            [self showDefaultSplash:[[self view] frame]];
        }
        [NSTimer scheduledTimerWithTimeInterval:2.0
                                         target:self
                                       selector:@selector(closeSplash:)
                                       userInfo:nil
                                        repeats:NO];
    }
#endif
     */
    
    [self jumpToMessage];
}

-(void)jumpToMessage {
    if (HighlightedMessageID != 0) {
        CurrentMessage = [Data findMessageWithID:HighlightedMessageID];
        if (CurrentMessage != nil) {
            CurrentCategory = [CurrentMessage category];
            CurrentColorIndex = HighlightedMessageID % [colors count];
            HighlightedMessageID = 0;
            
            [self animateMessage];
        }
    }
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [Data reloadData];
}

-(void)showSkinSplash:(CGRect)frm {
    splash = [[UIImageView alloc] initWithFrame:frm];
    [splash setContentMode:UIViewContentModeScaleAspectFit];
    [splash setBackgroundColor:[UIColor blackColor]];
    if ([[Skin LaunchImageURL] count] > 0) {
        int l = (arc4random() % [[Skin LaunchImageURL] count]);
        NSString* launch = [[Skin LaunchImageURL] objectAtIndex:l];
        
        ImageDownloader* img = [[ImageDownloader alloc] initWithUrl:launch
                                                         forImgView:(UIImageView*)splash];
        [img load];
    }
    
    CGRect frmIcon = CGRectMake(10, frm.size.height - 100, 64, 64);
    UIImageView *icon = [[UIImageView alloc] initWithFrame:frmIcon];
    [icon setContentMode:UIViewContentModeScaleAspectFit];
    [icon setImage:[UIImage imageNamed:@"TransparentButterfly.png"]];
    [splash addSubview:icon];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
    CGRect frmLogo = CGRectMake((frm.size.width / 2) - 30, frm.size.height - 170, 60, 60);
    UIImageView *logo = [[UIImageView alloc] initWithFrame:frmLogo];
    ImageDownloader* imglogo = [[ImageDownloader alloc] initWithUrl:[Skin IconButtonURL]
                                                         forImgView:(UIImageView*)logo];
    [imglogo load];
    [logo setContentMode:UIViewContentModeScaleAspectFit];
    [splash addSubview:logo];
    
    CGRect frmTitle = CGRectMake(80, frm.size.height - 100, frm.size.width - 160, 44);
    UILabel* title = [[UILabel alloc] initWithFrame:frmTitle];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[TextUtil GetBoldFontForSize:28.0]];
    [title setTextColor:[Skin createColor1]];
    //[title setText:[NSString stringWithFormat:@"%@ %@", [Skin SkinName], bundleName]];
    [title setText:[NSString stringWithFormat:@"%@", bundleName]];
    [splash addSubview:title];
    
    [[self view] addSubview:splash];
    
    [NSThread sleepForTimeInterval:1.0];
}

-(void)showDefaultSplash:(CGRect)frm {
    splash = [[UIView alloc] initWithFrame:frm];
    [splash setBackgroundColor:[colors objectAtIndex:2]];
    CGFloat x = (frm.size.width - 246) / 2, y = (frm.size.height - 246) / 2;
    CGRect frmLogo = CGRectMake(x, y, 246, 246);
    UIImageView *logo = [[UIImageView alloc] initWithFrame:frmLogo];
    [logo setContentMode:UIViewContentModeScaleAspectFit];
    [logo setImage:[UIImage imageNamed:@"TransparentButterfly.png"]];
    [splash addSubview:logo];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    NSString *ver = infoDictionary[@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
    
    CGRect frmTitle = CGRectMake(10, y + frmLogo.size.height + 10, frm.size.width - 20, 44);
    UILabel* title = [[UILabel alloc] initWithFrame:frmTitle];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[TextUtil GetBoldFontForSize:44.0]];
    [title setTextColor:[UIColor whiteColor]];
    [title setText:bundleName];
    [splash addSubview:title];
    
    CGRect frmVersion = CGRectMake(frmTitle.origin.x,
                                   frmTitle.origin.y + frmTitle.size.height + 4,
                                   frmTitle.size.width, 32);
    
    UILabel* version = [[UILabel alloc] initWithFrame:frmVersion];
    [version setTextAlignment:NSTextAlignmentCenter];
    [version setFont:[TextUtil GetLightFontForSize:30.0]];
    [version setTextColor:[UIColor whiteColor]];
    [version setText:[NSString stringWithFormat:@"%@.%@", ver, build]];
    [splash addSubview:version];
    [[self view] addSubview:splash];
}

-(void)closeSplash:(NSTimer*)timer {
    [splash removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[[self navigationItem] backBarButtonItem] setTitle:@"Back"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dataRefresh {
    [self updateSkin];
    
    //If there's a highlighted category, filter on that category.
    // It came from a notification, so we should only have this set once.
    if (HighlightedCategoryID != -1) {
        HighlightedCategoryID = -1;
        
        for (MessageCategory* mc in [Data getCategories]) {
            if ([mc catid] == HighlightedCategoryID) {
                categoryFilter = [mc name];
                break;
            }
        }

        //Mark this category as selected
        for (int i=0; i < [[scrollerCategories subviews] count]; i++) {
            UIView* v = [[scrollerCategories subviews] objectAtIndex:i];
            if ([v isKindOfClass:[UIButton class]]) {
                UIButton* b = (UIButton*) v;
                [b setSelected:[categoryFilter isEqualToString:[[b titleLabel] text]]];
            }
        }
    }
    
    [messages reloadData];
    
    [self jumpToMessage];
    
    [refreshControl endRefreshing];

#ifdef OODLES
    if ([Data getCategory:@"Badges"] != nil) {
        UIImage* imgEvent = [UIImage imageNamed:@"Oodles__badge_for_top-right-corner_of_app_small"];
        UIImage *scaledSettings = [UIImage imageWithCGImage:[imgEvent CGImage]
                                                      scale:94.0/30
                                                orientation:(imgEvent.imageOrientation)];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:scaledSettings
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(gotoBadgeCategory:)];
        [[self navigationItem] setRightBarButtonItem: rightButton];
    }
    else {
        [[self navigationItem] setRightBarButtonItem: nil];
    }
#endif
}

/*
-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(nullable id)sender {
    if ([[segue identifier] isEqualToString:@"SendMessage"])
    {
        ContactsTableViewController* cvc = [segue destinationViewController];
        [cvc setGroupName:@""];
    }
}
 */

-(void)updateSkin {
    if (Skin != nil && [Skin SkinName] != nil) {
        colors = [NSArray arrayWithObjects:[Skin createColor1], [Skin createColor2], [Skin createColor3], nil];
        colorsText = [NSArray arrayWithObjects:[Skin createTextColor1], [Skin createTextColor2],
                      [Skin createTextColor3], nil];
        colorsTitle = [NSArray arrayWithArray:colors];
        
        UIColor* colorTint = [colorsText objectAtIndex:0];
        //UIColor* colorBkgd = [colors objectAtIndex:2];
        [[[self navigationController] navigationBar] setTintColor:colorTint];
        //[[[self navigationController] navigationBar] setBarTintColor:colorBkgd];
        UIImage* imgHome = [[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnHome setImage:imgHome forState:UIControlStateNormal];
        [btnHome setTintColor:colorTint];
        [btnHome setTitleColor:colorTint forState:UIControlStateNormal];
        UIImage* imgBadge = [[UIImage imageNamed:@"bandcamp"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* imgNotes = [[UIImage imageNamed:@"note-text"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnBadges setImage:imgBadge forState:UIControlStateNormal];
        [btnBadges setImage:imgNotes forState:UIControlStateSelected];
        [btnBadges setTintColor:colorTint];
        [btnBadges setTitleColor:colorTint forState:UIControlStateNormal];
        UIImage* imgGroup = [[UIImage imageNamed:@"account-multiple"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnGroup setImage:imgGroup forState:UIControlStateNormal];
        [btnGroup setTintColor:colorTint];
        [btnGroup setTitleColor:colorTint forState:UIControlStateNormal];
    }
    else {
        [self setColors];
        
        UIColor* colorTint = [colors objectAtIndex:2];// [UIColor colorWithRed:22.0/256 green:194.0/256 blue:223./256 alpha:1.0];
        [[[self navigationController] navigationBar] setTintColor:colorTint];
        UIImage* imgHome = [[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnHome setImage:imgHome forState:UIControlStateNormal];
        [btnHome setTintColor:colorTint];
        [btnHome setTitleColor:colorTint forState:UIControlStateNormal];
        UIImage* imgBadge = [[UIImage imageNamed:@"bandcamp"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnBadges setImage:imgBadge forState:UIControlStateNormal];
        [btnBadges setTintColor:colorTint];
        [btnBadges setTitleColor:colorTint forState:UIControlStateNormal];
        UIImage* imgGroup = [[UIImage imageNamed:@"account-multiple"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnGroup setImage:imgGroup forState:UIControlStateNormal];
        [btnGroup setTintColor:colorTint];
        [btnGroup setTitleColor:colorTint forState:UIControlStateNormal];
        
        [[self navigationItem] setTitle:@"TextMuse"];
        
        /*
        UIImage* o = [UIImage imageNamed:@"TextMuseButton"];
        UIImage *scaledO = [UIImage imageWithCGImage:[o CGImage]
                                               scale:60.0/30
                                         orientation:(o.imageOrientation)];
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:scaledO
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showCategoryList:)];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
         */
    }
    
    [self setupCategoryButton];
}

-(void) setupCategoryButton {
    //Clear out the old buttons
    while ([[scrollerCategories subviews] count] != 0) {
        UIView* v = [[scrollerCategories subviews] objectAtIndex:0];
        [v removeFromSuperview];
    }
    
    NSArray* categories = [Data getCategories];
    CGFloat scrollerHeight = [scrollerCategories frame].size.height;
    CGFloat widthBtn = 250, heightBtn = scrollerHeight;
    CGFloat widthTotal = 10, margin = 20;
    UIButton* btn = [self makeCategoryButton:allFilter
                                   withFrame:CGRectMake(widthTotal, 0, widthBtn, heightBtn)];
    widthTotal += [btn frame].size.width + margin;
    [scrollerCategories addSubview:btn];
    [btn setSelected:true];
    for (int i=0; i<[categories count]; i++) {
        btn = [self makeCategoryButton:[categories objectAtIndex:i]
                             withFrame:CGRectMake(widthTotal, 0, widthBtn, heightBtn)];
        widthTotal += [btn frame].size.width + margin;
        [scrollerCategories addSubview:btn];
    }
    
    [scrollerCategories setContentSize:CGSizeMake(widthTotal, scrollerHeight)];
}

- (UIButton*) makeCategoryButton:(NSString*)category withFrame:(CGRect)frame {
    UIButton* btn = [[UIButton alloc] initWithFrame:frame];
    [btn setTitle:category forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [[btn titleLabel] setFont:[TextUtil GetBoldFontForSize:20.0]];
    [btn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [[btn titleLabel] sizeToFit];
    [btn sizeToFit];
    [btn addTarget:self action:@selector(chooseCategory:) forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

-(void)chooseCategory:(id)sender {
    UIButton* btn = (UIButton*)sender;
    for (int i=0; i < [[scrollerCategories subviews] count]; i++) {
        UIView* v = [[scrollerCategories subviews] objectAtIndex:i];
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton* b = (UIButton*) v;
            [b setSelected:false];
        }
    }
    [btn setSelected:true];
    CurrentCategory = [[btn titleLabel] text];
    categoryFilter = [[btn titleLabel] text];
    CurrentMessage = nil;
    
    NSString* btnToolbar = [[categoryFilter lowercaseString] containsString:@"prayer"] ? btnAddPrayer : btnAddEvent;
    [self setupToolbarButton:btnToolbar];
    
    [messages reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == categoryTable)
        return [[Data getCategories] count] + 1;
    else if (showPinned)
        return [pinnedMessages count];
    else if (showEvents)
        return [[Data getEventMessages] count];// [[Data getMessagesForCategory:@"Events"] count];
    else if (![categoryFilter isEqualToString:allFilter])
        return [[Data getMessagesForCategory:categoryFilter] count];
    else
        return [[Data getAllMessages] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == categoryTable)
        return 46.0;
    else {
        Message* msg = nil;
        if (showPinned)
            msg = [pinnedMessages objectAtIndex:[indexPath row]];
        else if (showEvents)
            //[[Data getMessagesForCategory:@"Events"] objectAtIndex:[indexPath row]];
            msg = [[Data getEventMessages] objectAtIndex:[indexPath row]];
        else if (![categoryFilter isEqualToString:allFilter])
            msg = [[Data getMessagesForCategory:categoryFilter] objectAtIndex:[indexPath row]];
        else
            msg = [[Data getAllMessages] objectAtIndex:[indexPath row]];
        CGFloat ret = [MessageTableViewCell GetCellHeightForMessage:msg inSize:[[self view] frame].size];
        if (ret <= 0 || ret >= [[self view] frame].size.height)
            ret = 120;  //just guess
        return ret;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == categoryTable) {
        return [self createCategoryCell:[indexPath row] forWidth:([[self view] frame].size.width / 2)];
    }
    else {
        static NSString *TextCellIdentifier = @"txtmessages";
        static NSString *ImgCellIdentifier = @"imgmessages";
        Message* msg = nil;
        if (showPinned)
            msg = [pinnedMessages objectAtIndex:[indexPath row]];
        else if (showEvents)
             //[[Data getMessagesForCategory:@"Events"] objectAtIndex:[indexPath row]];
            msg = [[Data getEventMessages] objectAtIndex:[indexPath row]];
        else if (![categoryFilter isEqualToString:allFilter])
            msg = [[Data getMessagesForCategory:categoryFilter] objectAtIndex:[indexPath row]];
        else
            msg = [[Data getAllMessages] objectAtIndex:[indexPath row]];
        
        MessageTableViewCell* cell = nil;
        if (cell == nil) {
            cell = ([msg mediaUrl] != nil) ?
                        [[ImageMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:ImgCellIdentifier] :
                        [[TextMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                        reuseIdentifier:TextCellIdentifier];
            [cell setTableView:tableView];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell showForSize:[tableView frame].size
              usingParent:self
                 withColor:[colors objectAtIndex:[indexPath row]%[colors count]]
                 textColor:[colorsText objectAtIndex:[indexPath row]%[colors count]]
                titleColor:[colorsTitle objectAtIndex:[indexPath row]%[colors count]]
                     title:showPinned ? @"pinned" : [msg category]
                   sponsor:showPinned ? nil : [[Data getCategory:[msg category]] sponsor]
                   message:msg];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == categoryTable) {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        CurrentCategory = [[cell textLabel] text];
        categoryFilter = [[cell textLabel] text];
        CurrentMessage = nil;

        CurrentColorIndex = [indexPath row] % [colors count];
        
        [self hideCategoryList];
        
        [messages reloadData];
    }
    else {
        if (showPinned)
            CurrentMessage = [pinnedMessages objectAtIndex:[indexPath row]];
        else if (showEvents)
            // [[Data getMessagesForCategory:@"Events"] objectAtIndex:[indexPath row]];
            CurrentMessage = [[Data getEventMessages] objectAtIndex:[indexPath row]];
        else if (![categoryFilter isEqualToString:allFilter])
            CurrentMessage = [[Data getMessagesForCategory:categoryFilter] objectAtIndex:[indexPath row]];
        else
            CurrentMessage = [[Data getAllMessages] objectAtIndex:[indexPath row]];
        CurrentCategory = showPinned ? @"PinnedMessages" : [CurrentMessage category];

        [self hideCategoryList];

        //[self performSegueWithIdentifier:@"SelectMessage" sender:self];
        
        [self animateMessage];

        if (Tour != nil) {
            GuidedTourStepView* gv = [[GuidedTourStepView alloc] initWithStep:[Tour getStepForKey:[Tour TextIt]] forFrame:[[self view] frame]];
            [[self view] addSubview:gv];
            [[self view] bringSubviewToFront:gv];
        }
        else if ([CurrentMessage sponsorID] > 0 && ShowSponsor) {
            GuidedTour* tour = [[GuidedTour alloc] init];
            NSArray* params = [NSArray arrayWithObjects:[CurrentMessage sponsorName],
                                [CurrentMessage sponsorName],
                                nil];
            GuidedTourStepView* gv =
            [[GuidedTourStepView alloc] initWithStep:[tour getStepForKey:[tour Sponsor]]
                                            forFrame:[[self view] frame]
                                          withParams:params];
            [[self view] addSubview:gv];
            [[self view] bringSubviewToFront:gv];
            ShowSponsor = false;
            [Settings SaveSetting:SettingShowSponsor withValue:@"0"];
        }
        else if ([CurrentMessage sendcount] > 0 && ShowBadge) {
            GuidedTour* tour = [[GuidedTour alloc] init];
            NSArray* params = [NSArray arrayWithObjects:
                               [CurrentMessage sponsorName],
                               [NSString stringWithFormat:@"%d", [CurrentMessage sendcount]],
                               [CurrentMessage sponsorName],
                               nil];
            GuidedTourStepView* gv = [[GuidedTourStepView alloc]
                                      initWithStep:[tour getStepForKey:[tour Badge]]
                                      forFrame:[[self view] frame]
                                      withParams:params];
            [[self view] addSubview:gv];
            [[self view] bringSubviewToFront:gv];
            ShowBadge = false;
            [Settings SaveSetting:SettingShowBadge withValue:@"0"];
        }
    }
}

-(void) animateMessage {
    CGFloat top = 60;
    /*
     //Slide from top
    CGRect frmEnd = [[self view] frame];
    frmEnd.origin.y += top;
    frmEnd.size.height -= top;
    CGRect frmStart = frmEnd;
    frmStart.origin.y -= frmStart.size.height;
     */
    // Slide from left
    CGRect frmEnd = [[self view] frame];
    frmEnd.origin.y += top;
    frmEnd.size.height -= top;
    CGRect frmStart = frmEnd;
    frmStart.origin.x -= frmStart.size.width;
    mv = [MessageView setupViewForMessage:CurrentMessage
                                  inFrame:frmEnd
                               withBadges:YES
                               fullScreen:YES
                                withColor:[colors objectAtIndex:CurrentColorIndex]
                                    index:CurrentColorIndex];

    [mv setTarget:self withSelector:@selector(chooseMessage:) andQuickSend:@selector(quickMessage:)];
    [mv setFrame: frmStart];
    [[self view] addSubview:mv];
    
    [UIView animateWithDuration:0.5
                     animations: ^{ [self->mv setFrame: frmEnd]; }
                     completion: nil];
}

-(IBAction)chooseMessage:(id)sender {
    if (Tour != nil) {
        GuidedTourStepView* gv = [[GuidedTourStepView alloc] initWithStep:[Tour getStepForKey:[Tour ChooseContact]]
                                                                 forFrame:[[self view] frame]
                                                        completionHandler:^(void){[self choseMessage];}
                                  ];
        [[self view] addSubview:gv];
        [[self view] bringSubviewToFront:gv];
    }
    else
        [self choseMessage];
}

-(void)choseMessage {
    if ([CurrentMessage badge]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Remit badge?"
                                                        message:@"Are you sure you want to remit this badge?"
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Yes Button", nil)
                                              otherButtonTitles:NSLocalizedString(@"No Button", nil), nil];
        [alert show];
    }
    else if ([CurrentMessage isPrayer])
        [CurrentMessage submitPrayFor];
    else {
        //Block for showing the ContactPickerViewController
        void (^showCVC)(void) = ^{
            [Data initContacts];
            [self performSegueWithIdentifier:@"SendMessage" sender:self];
        };

        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError* err) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), showCVC);
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self->sendMessage sendMessageTo:nil from:self];
                    });
                }
            }
             ];
        }
        else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
            showCVC();
        }
        else
            [sendMessage sendMessageTo:nil from:self];
    }
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    NSArray<CNContact*>* cs = [NSArray arrayWithObject:contact];
    [self contactPicker:picker didSelectContacts:cs];
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts {
    void(^showSendMsg)(void) = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray* usercontacts = [[NSMutableArray alloc] init];
            for (CNContact* c in contacts) {
                NSMutableArray* phones = [[NSMutableArray alloc] init];
                for (CNPhoneNumber* p in [c phoneNumbers]) {
                    UserPhone* up = [[UserPhone alloc] initWithNumber:[[p valueForKey:@"value"] valueForKey:@"digits"]
                                                                Label:[p valueForKey:@"label"]];
                    [phones addObject:up];
                }
                UserContact* uc = [[UserContact alloc] initWithFName:[c givenName] LName:[c familyName] Phones:phones Photo:[c imageData]];
                [usercontacts addObject:uc];
            }
            
            [self->sendMessage sendMessageTo:usercontacts from:self];
        });
    };
    
    [self dismissViewControllerAnimated:YES completion:showSendMsg];
}

-(IBAction)quickMessage:(id)sender {
    Message* m = CurrentMessage;
    CurrentMessage = [[Message alloc] init];
    [CurrentMessage setText:@""];
    [CurrentMessage setQuicksend:YES];
    [sendMessage sendMessageTo:[NSArray arrayWithObject:[m textno]] from:self];
    CurrentMessage = m;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [SqlDb flagMessage:CurrentMessage];
        [Data reloadData];
        
        NSMutableURLRequest* req = nil;
        req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlRemitBadge]
                                      cachePolicy:NSURLRequestReloadIgnoringCacheData
                                  timeoutInterval:30];
        [req setHTTPBody:[[NSString stringWithFormat:@"app=%@&game=%ld", AppID, -1*(long)[CurrentMessage msgId]]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [req setHTTPMethod:@"POST"];
        NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                                delegate:nil
                                                        startImmediately:YES];
        
        [mv close:nil];
    }
}


-(UITableViewCell*)createCategoryCell:(long)iCategory forWidth:(CGFloat)width {
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    [cell setBackgroundColor:[UIColor lightGrayColor]];
    [[cell textLabel] setTextColor:[UIColor blackColor]];
    NSString* categoryName = (iCategory == 0) ? allFilter : [[Data getCategories] objectAtIndex:iCategory-1];
    [[cell textLabel] setText:categoryName];
    if (categoryName == categoryFilter)
        [[cell textLabel] setFont:[TextUtil GetBoldFontForSize:20.0]];
    else
        [[cell textLabel] setFont:[TextUtil GetLightFontForSize:20.0]];
    
    return cell;
}

-(IBAction)home:(id)sender {
    showPinned = false;
    [messages reloadData];
    
    [messages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                    atScrollPosition:UITableViewScrollPositionTop
                            animated:YES];
}

-(IBAction)showPinned:(id)sender {
    showEvents = false;
    if ([[Data getPinnedMessages] count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Pinned Messages"
                                                        message:@"You don't have any pinned messages yet. Click on the pin icon for a message you want to save, and it will be displayed here."
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        pinnedMessages = [Data getPinnedMessages];
        showPinned = true;
        [messages reloadData];
        [messages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                        atScrollPosition:UITableViewScrollPositionTop
                                animated:YES];
    }
}

-(IBAction)addEvent:(id)sender {
    AddContent = [[[self navigationItem] rightBarButtonItem] tag];
    [self performSegueWithIdentifier:@"AddEvent" sender:self];
    
}

-(IBAction)gotoBadgeCategory:(id)sender {
    CurrentCategory = @"Badges";
    CurrentColorIndex = 0;

    [self performSegueWithIdentifier:@"SelectMessage" sender:self];
}

-(IBAction)showBadges:(id)sender {
    [self performSegueWithIdentifier:@"ViewBadges" sender:self];
}

-(long) chosenCategory:(long)selectedCategory {
    long icategory = selectedCategory;
    if (CategoryList != nil) {
        NSArray* cats = [Data getCategories];
        int ichosen = 0;
        for (icategory = 0; icategory<[cats count]; icategory++) {
            NSString* tmp = [cats objectAtIndex:icategory];
            if (![[CategoryList objectForKey:tmp] isEqualToString:@"0"]) {
                if (ichosen == selectedCategory)
                    break;
                else
                    ichosen++;
            }
        }
        if (icategory == [cats count])
            NSLog(@"I don't expect to be here ...");
    }
    
    return icategory;
}

-(IBAction)settings:(id)sender {
    [self performSegueWithIdentifier:@"Settings" sender:self];
}

-(IBAction)website:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Skin HomeURL]]];
}

-(IBAction)showCategoryList:(id)sender {
    if (categoryTable == nil) {
        UIView* parent = [messages superview];
        CGRect frmTable = [messages frame];
        frmTable.size.width = 2*[messages frame].size.width / 3;
        frmTable.origin.x = [messages frame].size.width / 6;
        //frmTable.size.height = 2*[messages frame].size.height / 3;
        frmTable.size.height = MIN(46*([[Data getCategories] count]+1), [messages frame].size.height-50);
        CGRect frmNext = frmTable;
        frmTable.size.height = 0;
        categoryTable = [[UITableView alloc] initWithFrame:frmTable];
        [categoryTable setDelegate:self];
        [categoryTable setDataSource:self];
        [categoryTable setBackgroundColor:[UIColor lightGrayColor]];
        
        [parent addSubview:categoryTable];
        [UIView animateWithDuration:0.5 animations:^{[self->categoryTable setFrame:frmNext];}];
    }
    else {
        [self hideCategoryList];
    }
}

-(void)hideCategoryList {
    CGRect frmNext = [categoryTable frame];
    frmNext.size.height = 0;
    [UIView animateWithDuration:0.5
                     animations:^{[self->categoryTable setFrame:frmNext];}
                     completion:^(BOOL finished){
                         [self->categoryTable removeFromSuperview];
                         self->categoryTable = nil;
                     }];
}

/*
-(void)showGuidedTour {
    GuidedTourStepView* gv = [[GuidedTourStepView alloc] initWithStep:[Tour getStepForKey:[Tour Intro]] forFrame:[[self view] frame]];
    [[self view] addSubview:gv];
}
*/
/*
-(void)showWalkthrough {
    [self showGuidedTour];
    return;
 
    CGRect frmView = [messages frame];// [[self view] frame];
    //frmView.origin.y += 60;
    //frmView.size.height -= 60;
    walkthroughView = [[UIView alloc] initWithFrame:frmView];
    [walkthroughView setBackgroundColor:[UIColor whiteColor]];
    [[self view] addSubview:walkthroughView];
    frmView = [walkthroughView frame];
    
    CGRect frmClose = CGRectMake(frmView.size.width-60, 10, 50, 30);
    UIButton* btnClose = [[UIButton alloc] initWithFrame:frmClose];
    [btnClose setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnClose setTitle:@"Done" forState:UIControlStateNormal];
    [[btnClose titleLabel] setFont:[TextUtil GetDefaultFontForSize:15.0]];
    [btnClose addTarget:self action:@selector(closeWalkthrough:)
       forControlEvents:UIControlEventTouchUpInside];
    [walkthroughView addSubview:btnClose];
    
    CGRect frmPages = CGRectMake(10, frmView.size.height-57, frmView.size.width-20, 37);
    pages = [[UIPageControl alloc] initWithFrame:frmPages];
    [pages setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [pages setCurrentPageIndicatorTintColor:[UIColor blackColor]];
    [pages addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [walkthroughView addSubview:pages];
    
    CGRect frmScroll = CGRectMake(0, 50, frmView.size.width, frmPages.origin.y - 60);
    scroller = [[UIScrollView alloc] initWithFrame:frmScroll];
    [scroller setShowsHorizontalScrollIndicator:NO];
    [scroller setShowsVerticalScrollIndicator:NO];
    [scroller setPagingEnabled:YES];
    [scroller setDelegate:self];
    [walkthroughView addSubview:scroller];
    
    int pagecount = 5;
#ifdef OODLES
    pagecount = 6;
#endif
    [pages setNumberOfPages:pagecount];
    int x = 0;
#ifdef UNIVERSITY
    // mdpi: 166 X 288
    // hdpi: 252 X 437
    // xhdpi: 333 X 577
    // xxhdpi: 504 X 874
    NSString* images[] = {
        @"walkthru_one", @"walkthru_two", @"walkthru_three", @"walkthru_four", @"walkthru_five"
    };
    NSString* txts[] = {
        @"Every day, you’ll find great local deals, great events, university news and other fun stuff.",
        @"Choose a text to share it with friends, see more, or follow the sponsor.",
        @"Choose a friend or group. If they have more than one number, swipe left and select the best number ...",
        @"... and before you send it, edit it to give it that personal touch.",
        @"Touch the cog to personalize TextMuse – choose which categories you want to see and send us feedback."
    };
#endif
#ifdef OODLES
    NSString* images[] = {
        @"Oodles_Logo_BIG_final_400", @"oodles_two", @"ScrSht_3", @"ScrSht_4", @"ScrSht_5", @"Oodles_Logo_BIG_final_400"
    };
    NSString* txts[] = {
        @"Oodles gives you and your friends hot deals and events around campus. And the more you do together, the more you get!",
        @"Oodles features three types of content. Food and drink deals, Campus Located Events and Student Generated Events.",
        @"Tier #1, just show the hot deal or event in-app to the vendor and enjoy. Many of these can only be found on Oodles.",
        @"Tier #2, share the hot deal or event with your friends to get a better deal.",
        @"Tier #3, enjoy the hot deal or event together with your friends for maximum value.",
        @"So, go out there and have Oodles & Oodles of fun on campus with your friends."
    };
#endif
#ifdef HUMANIX
    NSString* images[] = {};
    NSString* txts[] = {};
#endif
#ifdef YOUTHREACH
    NSString* images[] = {};
    NSString* txts[] = {};
#endif
#ifdef NRCC
    NSString* images[] = {};
    NSString* txts[] = {};
#endif
    CGFloat txtHeight = 80;
    frmScroll.size.height -= frmScroll.origin.y;
    for (int i=0; i<pagecount; i++) {
        CGRect frmHeader = CGRectMake(x + 10, 10, frmScroll.size.width - 20, 24);
        CGRect frmText = CGRectMake(x + 10, frmScroll.size.height - txtHeight,
                                    frmScroll.size.width - 20, txtHeight);
        CGRect frmImg = CGRectMake(x, 10, frmScroll.size.width, frmScroll.size.height - txtHeight - 10);
        if (i == 0) {
            frmImg.origin.y = 40;
            frmImg.size.height -= 40;
            
            UILabel* hdr = [[UILabel alloc] initWithFrame:frmHeader];
#ifdef UNIVERSITY
            [hdr setText:@"Welcome to TextMuse!"];
#endif
#ifdef OODLES
            [hdr setText:@"Welcome to Oodles!"];
#endif
            [hdr setFont:[TextUtil GetDefaultFontForSize:24.0]];
            [hdr setTextColor:[UIColor blackColor]];
            [hdr setTextAlignment:NSTextAlignmentCenter];
            [scroller addSubview:hdr];
        }
        
        UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:images[i]]];
        [img setFrame:frmImg];
        [img setContentMode:UIViewContentModeScaleAspectFit];
        [scroller addSubview:img];
        
        UILabel* lbl = [[UILabel alloc] initWithFrame:frmText];
        //[lbl sizeToFit];
        [lbl setText:txts[i]];
        CGFloat fntSize = frmText.size.width > 330 ? 18 : 14;
        [lbl setFont:[TextUtil GetDefaultFontForSize:fntSize]];
        [lbl setTextColor:[UIColor blackColor]];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setNumberOfLines:0];
        [scroller addSubview:lbl];
        
        x += frmScroll.size.width;
    }
    [scroller setContentSize:CGSizeMake(frmScroll.size.width*pagecount, frmScroll.size.height)];
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
}
*/

-(void)showChooseSkin {
    CGRect frm = [[self view] frame];
    CGFloat topmargin = 32; // frmNav.size.height;
    frm.origin.y = topmargin; // + frm.size.height;
    frm.size.height -= topmargin;
    
    ChooseSkinView* skinview =
        [[ChooseSkinView alloc] initWithFrame:frm
                                     complete:^{ [self performRegistration]; }];
    [[self view] addSubview:skinview];
}

-(void)closeSkin {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != scroller)
        return;
    
    CGFloat pageWidth = [scroller frame].size.width;
    float fractionalPage = [scroller contentOffset].x / pageWidth;
    NSInteger page = lround(fractionalPage);
    [pages setCurrentPage: page];
}

- (IBAction)pageTurn:(id)sender {
    long page = [pages currentPage];
    CGRect frm = [scroller frame];
    CGPoint p = [scroller contentOffset];
    [scroller setContentOffset:CGPointMake(page * frm.size.width, p.y)];
}

-(IBAction)closeWalkthrough:(id)sender {
    [walkthroughView removeFromSuperview];
#ifdef UNIVERSITY
    [self performRegistration];
#endif
#ifdef OODLES
    [self performRegistration];
#endif
    
    [Settings SaveSetting:SettingShowIntro withValue:@"0"];
}

-(void)performRegistration {
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    [[[self navigationItem] backBarButtonItem] setTitle:@"Skip"];
    ShowIntro = NO;
    [self performSegueWithIdentifier:@"registerInitial" sender:self];
}

@end
