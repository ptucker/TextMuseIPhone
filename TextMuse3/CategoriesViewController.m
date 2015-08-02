//
//  ViewController.m
//  TextMuse2
//
//  Created by Peter Tucker on 4/18/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "CategoriesViewController.h"
#import "WalkthroughViewController.h"
#import "CategoriesTableViewCell.h"
#import "MessageCategory.h"
#import "Message.h"
#import "ImageDownloader.h"
#import "Settings.h"

NSArray* colors;
NSArray* colorsText;
NSArray* colorsTitle;

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (colors == nil)
        [self setColors];

    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [categories addSubview:refreshControl];
    
    UIImage* settings = [UIImage imageNamed:@"gear.png"];
    UIImage *scaledSettings = [UIImage imageWithCGImage:[settings CGImage]
                                                  scale:73.0/30
                                            orientation:(settings.imageOrientation)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:scaledSettings
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(settings:)];
    [[self navigationItem] setRightBarButtonItem: rightButton];
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    
    CGRect frmSuggestion = [randomMessages frame];
    frmSuggestion.origin.x = 0;
    frmSuggestion.origin.y = 0;
    [randomMessages setContentSize:frmSuggestion.size];

    if (ShowIntro) {
        [self showWalkthrough];
    }
    
    [Data addListener:self];
    
    [randomMessages setDelegate:self];

    [categories setDelegate:self];
    [categories setDataSource:self];
    
    [categories reloadData];
    [categories setBackgroundColor:[UIColor whiteColor]];
#ifdef WHITWORTH
    [[self navigationItem] setTitle:@"Whitworth TextMuse"];

    UIImage* o = [UIImage imageNamed:@"w.png"];
    UIImage *scaledO = [UIImage imageWithCGImage:[o CGImage]
                                           scale:174.0/30
                                     orientation:(o.imageOrientation)];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:scaledO
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(website:)];
    [[self navigationItem] setLeftBarButtonItem:leftButton];
#endif
#ifdef UOREGON
    [[self navigationItem] setTitle:@"Oregon TextMuse"];

    UIImage* o = [UIImage imageNamed:@"o.png"];
    UIImage *scaledO = [UIImage imageWithCGImage:[o CGImage]
                                           scale:263.0/30
                                     orientation:(o.imageOrientation)];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:scaledO
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(website:)];
    [[self navigationItem] setLeftBarButtonItem:leftButton];
#endif
}

-(void)setColors {
    colorsText = [NSArray arrayWithObjects:[UIColor whiteColor], [UIColor whiteColor], [UIColor whiteColor],
                  nil];
#ifdef WHITWORTH
    //Crimson, Black, Grey
    colors = [NSArray arrayWithObjects: [UIColor colorWithRed:194/255.0 green:2/255.0 blue:2/255.0 alpha:1.0], [UIColor blackColor], [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0], nil];
#endif
#ifdef UOREGON
    //Yellow, Green, Grey
    colors = [NSArray arrayWithObjects: [UIColor colorWithRed:255/255.0 green:2382/255.0 blue:2/255.0 alpha:1.0], [UIColor colorWithRed:0/255.0 green:73/255.0 blue:0/255.0 alpha:1.0], [UIColor colorWithRed:105/255.0 green:107/255.0 blue:106/255.0 alpha:1.0], nil];
    colorsText = [NSArray arrayWithObjects:[UIColor blackColor], [UIColor whiteColor], [UIColor whiteColor], nil];
    colorsTitle = [NSArray arrayWithObjects:[UIColor blackColor], [colors objectAtIndex:1], [colors objectAtIndex:2], nil];
#endif
    if (colors == nil)
        //Green, Orange, Blue
        colors = [NSArray arrayWithObjects: [UIColor colorWithRed:0/255.0 green:172/255.0 blue:101/255.0 alpha:1.0], [UIColor colorWithRed:233/255.0 green:102/255.0 blue:44/255.0 alpha:1.0], [UIColor colorWithRed:22/255.0 green:194/255.0 blue:239/255.0 alpha:1.0], nil];
    if (colorsTitle == nil)
        colorsTitle = [NSArray arrayWithObjects:[colors objectAtIndex:0], [colors objectAtIndex:1],
                       [colors objectAtIndex:2], nil];

}

- (void)viewDidAppear:(BOOL)animated {
    reminderButtonState = SHOW_TEXT;
    [[[self  navigationItem] backBarButtonItem] setTitle:@"Back"];
    
    if (timerReminder == nil) {
        timerReminder = [NSTimer scheduledTimerWithTimeInterval:HIGHLIGHTED_INTERVAL
                                                         target:self
                                                       selector:@selector(setReminder:)
                                                       userInfo:nil
                                                        repeats:YES];
    }

    //Call this right away
    [self setReminder:timerReminder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [Data reloadData];
}

-(void)dataRefresh {
    [categories reloadData];
    
    [refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger c = [[Data getCategories] count];
    if (CategoryList != nil) {
        int cnt = 0;
        for (NSString* cat in [CategoryList keyEnumerator]) {
            if ([[CategoryList objectForKey:cat] isEqualToString: @"1"])
                cnt++;
        }
        c = cnt;
    }
    
    return c;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 190.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"categories";
    CategoriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CategoriesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    long icategory = [self chosenCategory:[indexPath row]];

    NSString* category;
    Message* msg = nil;
    NSArray* cs = [Data getCategories];
    if (icategory >= [[Data getCategories] count])
        icategory = [[Data getCategories] count] - 1;
    category = [cs objectAtIndex:icategory];
    if ([[Data getMessagesForCategory:category] count] != 0)
        msg = [[Data getMessagesForCategory:category] objectAtIndex:0];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell showForWidth:[[self view] frame].size.width
             withColor:[colors objectAtIndex:[indexPath row]%[colors count]]
             textColor:[colorsText objectAtIndex:[indexPath row]%[colors count]]
            titleColor:[colorsTitle objectAtIndex:[indexPath row]%[colors count]]
                 title:category
              newCount:[Data getNewMessageCountForCategory:category]
               message:msg];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    long icategory = [self chosenCategory:[indexPath row]];

    CurrentColorIndex = icategory % [colors count];
    if (icategory >= [[Data getCategories] count])
        icategory = [[Data getCategories] count] - 1;
    CurrentCategory = [[Data getCategories] objectAtIndex:icategory];
    CurrentMessage = nil;
    
    [self performSegueWithIdentifier:@"SelectMessage" sender:self];
}

-(long) chosenCategory:(long)selectedCategory {
    long icategory = selectedCategory;
    if (CategoryList != nil) {
        NSArray* cats = [Data getCategories];
        int ichosen = 0;
        for (icategory = 0; icategory<[cats count]; icategory++) {
            NSString* tmp = [cats objectAtIndex:icategory];
            if ([[CategoryList objectForKey:tmp] isEqualToString:@"1"]) {
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

-(IBAction)sendRandomMessage:(id)sender {
    UISuggestionButton* btn = (UISuggestionButton*)sender;
    CurrentMessage = [btn message];
    CurrentCategory = [[btn message] category];
    [self performSegueWithIdentifier:@"SelectMessage" sender:self];
}

-(IBAction)settings:(id)sender {
    [self performSegueWithIdentifier:@"Settings" sender:self];
}

#ifdef UOREGON
-(IBAction)website:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.goducks.com"]];
}
#endif
#ifdef WHITWORTH
-(IBAction)website:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.whitworthpirates.com"]];
}
#endif

-(UISuggestionButton*) addMessageButton:(Message*)msg {
    CGRect frmScroll = [randomMessages frame];
    CGRect frmButton = CGRectMake([randomMessages contentSize].width, 0,
                                  frmScroll.size.width, frmScroll.size.height);
    
    UISuggestionButton* btnSuggestion = [[UISuggestionButton alloc] initWithMessage:msg];
    [btnSuggestion setFrame:frmButton];
    CGRect frmLabel = CGRectMake(0, 0, frmButton.size.width, frmButton.size.height);
    
    UILabel* lblSuggestion = [[UILabel alloc] initWithFrame:frmLabel];
    [lblSuggestion setFont:[UIFont fontWithName:@"Lato-Regular" size:24]];
    [lblSuggestion setTextAlignment:NSTextAlignmentCenter];
    [lblSuggestion setNumberOfLines:0];
    [lblSuggestion setTextColor:[UIColor whiteColor]];
    [lblSuggestion setTag:1];
    
    UIImageView* ivSuggestion = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              frmButton.size.width,
                                                                              frmButton.size.height)];
    [ivSuggestion setContentMode:UIViewContentModeScaleAspectFit];
    [ivSuggestion setTag:2];
    [btnSuggestion addSubview:ivSuggestion];
    [btnSuggestion addSubview:lblSuggestion];
    
    [btnSuggestion addTarget:self action:@selector(sendRandomMessage:)
            forControlEvents:UIControlEventTouchUpInside];
    
    return btnSuggestion;
}

-(void)setReminder:(NSTimer*)timer {
    if (reminderButtonState == TIMER_PAUSED)
        return;
    
    if (reminderButtonState == SHOW_CONTACT && [Data getContacts] == nil)
        reminderButtonState = SHOW_TEXT;
    unsigned long colorcount = [colors count];
    unsigned int icolor = rand() % colorcount;
    
    Message* msg = [Data chooseRandomMessage];
    UISuggestionButton* btnSuggestion = [self addMessageButton:msg];
    UILabel* lblSuggestion = (UILabel*)[btnSuggestion viewWithTag:1];
    UIImageView* ivSuggestion = (UIImageView*)[btnSuggestion viewWithTag:2];
    [btnSuggestion setBackgroundColor:[colors objectAtIndex:icolor]];
    while ([msg mediaUrl] != nil && [msg img] == nil) {
        ImageDownloader* load =
        [[ImageDownloader alloc] initWithUrl:[msg mediaUrl]
                                  forMessage:msg];
        [load load];
        msg = [Data chooseRandomMessage];
    }
    if (([msg text] == nil) || [[msg text] length] == 0) {
        [lblSuggestion setText:@""];
        [lblSuggestion setHidden:YES];
    }
    else {
        //[btnSuggestion1 setTitle:[randomMessage text] forState:UIControlStateNormal];
        [lblSuggestion setText:[msg text]];
        [lblSuggestion setTextColor:[colorsText objectAtIndex:icolor]];
        [lblSuggestion setHidden:NO];
    }
    if ([msg mediaUrl] == nil) {
        [btnSuggestion setBackgroundImage:nil forState:UIControlStateNormal];
        [lblSuggestion setFrame:CGRectMake(4, 4,
                                           [btnSuggestion frame].size.width-8,
                                           [btnSuggestion frame].size.height-8)];
        //[btnSuggestion1 setTitle:[randomMessage text] forState:UIControlStateNormal];
        [ivSuggestion setHidden:YES];
        [lblSuggestion setBackgroundColor:[UIColor clearColor]];
        [lblSuggestion setNumberOfLines:0];
        [lblSuggestion setAlpha:1];
    }
    else {
        CGRect frm = CGRectMake(0, [btnSuggestion frame].size.height-22,
                                [btnSuggestion frame].size.width, 22);
        [ivSuggestion setImage:[UIImage imageWithData:[msg img]]];
        [ivSuggestion setHidden:NO];
        [lblSuggestion setFrame:frm];
        [lblSuggestion setNumberOfLines:1];
        [lblSuggestion setBackgroundColor:[UIColor grayColor]];
        [lblSuggestion setAlpha:0.70];
    }
    CGFloat newWidth = [randomMessages contentSize].width+[btnSuggestion frame].size.width;
    CGSize newSize = CGSizeMake(newWidth, [randomMessages frame].size.height);
    [randomMessages setContentSize:newSize];
    [randomMessages addSubview:btnSuggestion];
    CGRect frmNext = CGRectMake([randomMessages contentOffset].x, 0, [randomMessages frame].size.width,
                                [randomMessages frame].size.height);
    frmNext.origin.x += [randomMessages frame].size.width;
    frmNext.origin.x -= (int)(frmNext.origin.x+1) % (int)frmNext.size.width;
    
    [randomMessages scrollRectToVisible:frmNext animated:YES];
    
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

-(IBAction)closeWalkthrough:(id)sender {
    [walkthroughView removeFromSuperview];
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    [[[self  navigationItem] backBarButtonItem] setTitle:@"Skip"];
    ShowIntro = NO;
    [self performSegueWithIdentifier:@"registerInitial" sender:self];
    
    [Settings SaveSetting:SettingShowIntro withValue:@"0"];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender == randomMessages) {
        [sender setContentOffset:CGPointMake([sender contentOffset].x, 0)];
    }
}

@end
