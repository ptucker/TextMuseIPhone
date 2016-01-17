//
//  RndMessagesViewController.m
//  TextMuse
//
//  Created by Peter Tucker on 12/26/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import "RndMessagesViewController.h"
#import "WalkthroughViewController.h"
#import "ImageMessageTableViewCell.h"
#import "TextMessageTableViewCell.h"
#import "MessageCategory.h"
#import "Message.h"
#import "ImageDownloader.h"
#import "Settings.h"
#import "ChooseSkinView.h"
#import "UICheckButton.h"
#import "ContactsTableViewController.h"

NSArray* colors;
NSArray* colorsText;
NSArray* colorsTitle;

@interface RndMessagesViewController ()

@end

@implementation RndMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frmMessages = CGRectMake(0, 65, [[self view] frame].size.width,
                                    [[self view] frame].size.height - 65 - 40);
    messages = [[UITableView alloc] initWithFrame:frmMessages];
    [[self view] addSubview:messages];
    showPinned = false;
    
    if (colors == nil)
        [self setColors];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [messages addSubview:refreshControl];
    
    UIImage* settings = [UIImage imageNamed:@"gear.png"];
    UIImage *scaledSettings = [UIImage imageWithCGImage:[settings CGImage]
                                                  scale:73.0/30
                                            orientation:(settings.imageOrientation)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:scaledSettings
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(settings:)];
    [[self navigationItem] setRightBarButtonItem: rightButton];
    [[self navigationController] setDelegate:self];
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    
    if (ShowIntro) {
        [self showWalkthrough];
        
        [self showChooseSkin];
    }
    
    [Data addListener:self];
    
    [messages setDelegate:self];
    [messages setDataSource:self];
    
    [messages setBackgroundColor:[UIColor whiteColor]];
    
    if (Skin != nil) {
        [[self navigationItem] setTitle:[NSString stringWithFormat:@"%@ TextMuse", [Skin SkinName]]];
        ImageDownloader* downloader = [[ImageDownloader alloc] initWithUrl:[Skin IconButtonURL]
                                               forNavigationItemLeftButton:[self navigationItem]
                                                                withTarget:self
                                                              withSelector:@selector(showCategoryList:)];
        [downloader load];
    }
    else {
        UIImage* o = [UIImage imageNamed:@"TextMuseButton"];
        UIImage *scaledO = [UIImage imageWithCGImage:[o CGImage]
                                               scale:60.0/30
                                         orientation:(o.imageOrientation)];
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:scaledO
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showCategoryList:)];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
    }
}

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated {
    if (viewController == self)
        [messages reloadData];
}

-(void)setColors {
    colorsText = [NSArray arrayWithObjects:[UIColor blackColor], [UIColor blackColor], [UIColor blackColor],
                  nil];
#ifdef WHITWORTH
    //Crimson, Black, Grey
    colors = [NSArray arrayWithObjects: [UIColor colorWithRed:194/255.0 green:2/255.0 blue:2/255.0 alpha:1.0], [UIColor blackColor], [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0], nil];
#endif
#ifdef UOREGON
    //Yellow, Green, Grey
    colors = [NSArray arrayWithObjects: [UIColor colorWithRed:255/255.0 green:239/255.0 blue:1/255.0 alpha:1.0], [UIColor colorWithRed:0/255.0 green:73/255.0 blue:0/255.0 alpha:1.0], [UIColor colorWithRed:105/255.0 green:107/255.0 blue:106/255.0 alpha:1.0], nil];
    colorsText = [NSArray arrayWithObjects:[UIColor blackColor], [UIColor whiteColor], [UIColor whiteColor], nil];
    colorsTitle = [NSArray arrayWithObjects:[UIColor blackColor], [colors objectAtIndex:1], [colors objectAtIndex:2], nil];
#endif
    if (Skin != nil) {
        colors = [NSArray arrayWithObjects:[Skin createColor1], [Skin createColor2], [Skin createColor3], nil];
        colorsText = [NSArray arrayWithObjects:[Skin createTextColor1], [Skin createTextColor2], [Skin createTextColor3], nil];
        colorsTitle = [NSArray arrayWithArray:colors];
    }
    
    if (colors == nil)
        //Green, Orange, Blue
        colors = [NSArray arrayWithObjects: [UIColor colorWithRed:0/255.0 green:172/255.0 blue:101/255.0 alpha:1.0], [UIColor colorWithRed:233/255.0 green:102/255.0 blue:44/255.0 alpha:1.0], [UIColor colorWithRed:22/255.0 green:194/255.0 blue:239/255.0 alpha:1.0], nil];
    if (colorsTitle == nil)
        colorsTitle = [NSArray arrayWithObjects:[colors objectAtIndex:0], [colors objectAtIndex:1],
                       [colors objectAtIndex:2], nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    //Show splash screen for 2 seconds
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
    [title setFont:[UIFont fontWithName:@"Lato-Medium" size:28]];
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
    [title setFont:[UIFont fontWithName:@"Lato-Medium" size:44]];
    [title setTextColor:[UIColor whiteColor]];
    [title setText:bundleName];
    [splash addSubview:title];
    
    CGRect frmVersion = CGRectMake(frmTitle.origin.x,
                                   frmTitle.origin.y + frmTitle.size.height + 4,
                                   frmTitle.size.width, 32);
    
    UILabel* version = [[UILabel alloc] initWithFrame:frmVersion];
    [version setTextAlignment:NSTextAlignmentCenter];
    [version setFont:[UIFont fontWithName:@"Lato-Light" size:30]];
    [version setTextColor:[UIColor whiteColor]];
    [version setText:[NSString stringWithFormat:@"%@.%@", ver, build]];
    [splash addSubview:version];
    [[self view] addSubview:splash];
}

-(void)closeSplash:(NSTimer*)timer {
    [splash removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated {
    [[[self navigationItem] backBarButtonItem] setTitle:@"Back"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dataRefresh {
    [self updateSkin];
    
    [messages reloadData];
    
    [refreshControl endRefreshing];
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(nullable id)sender {
    if ([[segue identifier] isEqualToString:@"SendMessage"])
    {
        ContactsTableViewController* cvc = [segue destinationViewController];
        [cvc setGroupName:@""];
    }
}

-(void)updateSkin {
    if (Skin != nil && [Skin SkinName] != nil) {
        colors = [NSArray arrayWithObjects:[Skin createColor1], [Skin createColor2], [Skin createColor3], nil];
        colorsText = [NSArray arrayWithObjects:[Skin createTextColor1], [Skin createTextColor2],
                      [Skin createTextColor3], nil];
        colorsTitle = [NSArray arrayWithArray:colors];
        
        UIColor* colorTint = [Skin createColor1];
        [[[self navigationController] navigationBar] setTintColor:colorTint];
        UIImage* imgHome = [[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnHome setImage:imgHome forState:UIControlStateNormal];
        [btnHome setTintColor:colorTint];
        [btnHome setTitleColor:colorTint forState:UIControlStateNormal];
        UIImage* imgPin = [[UIImage imageNamed:@"pin_grey"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnPin setImage:imgPin forState:UIControlStateNormal];
        [btnPin setTintColor:colorTint];
        [btnPin setTitleColor:colorTint forState:UIControlStateNormal];
        UIImage* imgGroup = [[UIImage imageNamed:@"account-multiple"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnGroup setImage:imgGroup forState:UIControlStateNormal];
        [btnGroup setTintColor:colorTint];
        [btnGroup setTitleColor:colorTint forState:UIControlStateNormal];
        
        //[[self navigationItem] setTitle:[Skin MainWindowTitle]];
        [[self navigationItem] setTitle:[NSString stringWithFormat:@"%@ TextMuse", [Skin SkinName]]];
        
        ImageDownloader* downloader = [[ImageDownloader alloc] initWithUrl:[Skin IconButtonURL]
                                               forNavigationItemLeftButton:[self navigationItem]
                                                                withTarget:self
                                                              withSelector:@selector(showCategoryList:)];
        [downloader load];
    }
    else {
        //Green, Orange, Blue
        colors = [NSArray arrayWithObjects: [UIColor colorWithRed:0/255.0 green:172/255.0 blue:101/255.0 alpha:1.0], [UIColor colorWithRed:233/255.0 green:102/255.0 blue:44/255.0 alpha:1.0], [UIColor colorWithRed:22/255.0 green:194/255.0 blue:239/255.0 alpha:1.0], nil];
        colorsText = [NSArray arrayWithObjects:[UIColor blackColor], [UIColor blackColor],
                      [UIColor blackColor], nil];
        colorsTitle = [NSArray arrayWithObjects:[colors objectAtIndex:0], [colors objectAtIndex:1],
                       [colors objectAtIndex:2], nil];
        UIColor* colorTint = [UIColor colorWithRed:22.0/256 green:194.0/256 blue:223./256 alpha:1.0];
        [[[self navigationController] navigationBar] setTintColor:colorTint];
        UIImage* imgHome = [[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnHome setImage:imgHome forState:UIControlStateNormal];
        [btnHome setTintColor:colorTint];
        [btnHome setTitleColor:colorTint forState:UIControlStateNormal];
        UIImage* imgPin = [[UIImage imageNamed:@"pin_grey"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnPin setImage:imgPin forState:UIControlStateNormal];
        [btnPin setTintColor:colorTint];
        [btnPin setTitleColor:colorTint forState:UIControlStateNormal];
        UIImage* imgGroup = [[UIImage imageNamed:@"account-multiple"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnGroup setImage:imgGroup forState:UIControlStateNormal];
        [btnGroup setTintColor:colorTint];
        [btnGroup setTitleColor:colorTint forState:UIControlStateNormal];
        
        [[[self navigationItem] leftBarButtonItem] setImage:nil];
        
        [[self navigationItem] setTitle:@"TextMuse"];
        
        UIImage* o = [UIImage imageNamed:@"TextMuseButton"];
        UIImage *scaledO = [UIImage imageWithCGImage:[o CGImage]
                                               scale:60.0/30
                                         orientation:(o.imageOrientation)];
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:scaledO
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showCategoryList:)];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == categoryTable)
        return [[Data getCategories] count];
    else if (showPinned)
        return [pinnedMessages count];
    else
        return [[Data getAllMessages] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == categoryTable)
        return 46.0;
    else {
        Message* msg = showPinned ? [pinnedMessages objectAtIndex:[indexPath row]] :
                                    [[Data getAllMessages] objectAtIndex:[indexPath row]];
        return [MessageTableViewCell GetCellHeightForMessage:msg inSize:[[self view] frame].size];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == categoryTable) {
        return [self createCategoryCell:[indexPath row] forWidth:[tableView frame].size.width];
    }
    else {
        static NSString *TextCellIdentifier = @"txtmessages";
        static NSString *ImgCellIdentifier = @"imgmessages";
        Message* msg = showPinned ? [pinnedMessages objectAtIndex:[indexPath row]] :
                                    [[Data getAllMessages] objectAtIndex:[indexPath row]];
        /*
        MessageTableViewCell *cell = ([msg img] != nil) ?
                                    [tableView dequeueReusableCellWithIdentifier:ImgCellIdentifier] :
                                    [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier];
         */
        MessageTableViewCell* cell = nil;
        if (cell == nil) {
            cell = ([msg img] != nil) ?
                        [[ImageMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:ImgCellIdentifier] :
                        [[TextMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                        reuseIdentifier:TextCellIdentifier];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell showForSize:[[self view] frame].size
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
        long icategory = [self chosenCategory:[indexPath row]];
        if (icategory >= [[Data getCategories] count])
            icategory = [[Data getCategories] count] - 1;
        CurrentCategory = [[Data getCategories] objectAtIndex:icategory];
        CurrentMessage = nil;
    }
    else {
        CurrentMessage = showPinned ? [pinnedMessages objectAtIndex:[indexPath row]] :
                                      [[Data getAllMessages] objectAtIndex:[indexPath row]];
        CurrentCategory = showPinned ? @"PinnedMessages" : [CurrentMessage category];
    }
    
    CurrentColorIndex = [indexPath row] % [colors count];
    
    [self hideCategoryList];
    
    [self performSegueWithIdentifier:@"SelectMessage" sender:self];
}

-(UITableViewCell*)createCategoryCell:(long)iCategory forWidth:(CGFloat)width {
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    [cell setBackgroundColor:[UIColor blackColor]];
    [[cell textLabel] setTextColor:[UIColor whiteColor]];
    NSString* categoryName = [[Data getCategories] objectAtIndex:iCategory];
    [[cell textLabel] setText:categoryName];
    
    if (![[Data getRequiredCategories] containsObject:categoryName]) {
        CGRect frmCheck = CGRectMake(width-46, 2, 42, 42);
        UICheckButton* chk = [[UICheckButton alloc] initWithFrame:frmCheck];
        [chk setExtra:categoryName];
        [chk addTarget:self action:@selector(chooseCategory:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:chk];
        if ([CategoryList objectForKey:categoryName] == nil)
            [CategoryList setObject:@"1" forKey:categoryName];
        BOOL selected = ![[CategoryList objectForKey:categoryName] isEqualToString: @"0"];
        [chk setSelected:selected];
    }
    
    return cell;
}

-(IBAction)chooseCategory:(id)sender {
    UICheckButton* chk = (UICheckButton*)sender;
    [chk setSelected:![chk isSelected]];
    
    if ([[CategoryList objectForKey:[chk extra]] isEqualToString:@"0"])
        [CategoryList setObject:@"1" forKey:[chk extra]];
    else
        [CategoryList setObject:@"0" forKey:[chk extra]];

    [Settings SaveSetting:SettingCategoryList withValue:CategoryList];
    for (NSString*c in [Data getCategories]) {
        MessageCategory*mc = [Data getCategory:c];
        [mc setChosen:![[CategoryList objectForKey:c] isEqualToString:@"0"]];
    }
    
    [Data resortMessages];
    [self dataRefresh];
}

-(IBAction)home:(id)sender {
    showPinned = false;
    [messages reloadData];
    
    [messages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                    atScrollPosition:UITableViewScrollPositionTop
                            animated:YES];
}

-(IBAction)showPinned:(id)sender {
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
        frmTable.size.width = frmTable.size.width * 0.8;
        CGRect frmNext = frmTable;
        frmTable.origin.x = -frmTable.size.width;
        categoryTable = [[UITableView alloc] initWithFrame:frmTable];
        [categoryTable setDelegate:self];
        [categoryTable setDataSource:self];
        [categoryTable setBackgroundColor:[UIColor blackColor]];
        
        [parent addSubview:categoryTable];
        [UIView animateWithDuration:0.5 animations:^{[categoryTable setFrame:frmNext];}];
    }
    else {
        [self hideCategoryList];
    }
}

-(void)hideCategoryList {
    CGRect frmNext = [categoryTable frame];
    frmNext.origin.x = -frmNext.size.width;
    [UIView animateWithDuration:0.5
                     animations:^{[categoryTable setFrame:frmNext];}
                     completion:^(BOOL finished){
                         [categoryTable removeFromSuperview];
                         categoryTable = nil;
                     }];
}

-(void)showWalkthrough {
    CGRect frmView = [[self view] frame];
    frmView.origin.y += 60;
    frmView.size.height -= 60;
    walkthroughView = [[UIView alloc] initWithFrame:frmView];
    [walkthroughView setBackgroundColor:[UIColor whiteColor]];
    [[self view] addSubview:walkthroughView];
    frmView = [walkthroughView frame];
    
    CGRect frmClose = CGRectMake(frmView.size.width-60, 10, 50, 30);
    UIButton* btnClose = [[UIButton alloc] initWithFrame:frmClose];
    [btnClose setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnClose setTitle:@"Done" forState:UIControlStateNormal];
    [[btnClose titleLabel] setFont:[UIFont fontWithName:@"Lato-Regular" size:15]];
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
    [pages setNumberOfPages:pagecount];
    int x = 0;
    NSString* images[] = {
        @"categories.png", @"message.png", @"contacts.png", @"message_edit.png", @"settings.png"
    };
    NSString* txts[] = {
        @"Choose a category to find a text message you want to send your friends.",
        @"Swipe through and touch the text message you want to send.",
        @"After choosing a text, choose a contact or select a few and touch 'SEND'.",
        @"... and before you send it, you can make edits to give it that personal touch.",
        @"Touch the cog to personalize TextMuse. Adjust settings and send us your feedback!"
    };
    CGFloat txtHeight = 50;
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
            [hdr setText:@"Welcome to TextMuse!"];
            [hdr setFont:[UIFont fontWithName:@"Lato-Regular" size:24]];
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
        [lbl setFont:[UIFont fontWithName:@"Lato-Regular" size:fntSize]];
        [lbl setTextColor:[UIColor blackColor]];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setNumberOfLines:0];
        [scroller addSubview:lbl];
        
        x += frmScroll.size.width;
    }
    [scroller setContentSize:CGSizeMake(frmScroll.size.width*pagecount, frmScroll.size.height)];
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
}

-(void)showChooseSkin {
    CGRect frm = [[self view] frame];
    CGFloat topmargin = 32; // frmNav.size.height;
    frm.origin.y = topmargin; // + frm.size.height;
    frm.size.height -= topmargin;
    
    ChooseSkinView* skinview = [[ChooseSkinView alloc] initWithFrame:frm];
    [[self view] addSubview:skinview];
}

- (IBAction)pageTurn:(id)sender {
    long page = [pages currentPage];
    CGRect frm = [scroller frame];
    CGPoint p = [scroller contentOffset];
    [scroller setContentOffset:CGPointMake(page * frm.size.width, p.y)];
}

-(IBAction)closeWalkthrough:(id)sender {
    [walkthroughView removeFromSuperview];
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    [[[self  navigationItem] backBarButtonItem] setTitle:@"Skip"];
    ShowIntro = NO;
    [self performSegueWithIdentifier:@"registerInitial" sender:self];
    
    [Settings SaveSetting:SettingShowIntro withValue:@"0"];
}


@end
