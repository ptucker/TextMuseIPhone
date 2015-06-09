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

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (colors == nil)
        colors = [NSArray arrayWithObjects:
                  //Green
                  [UIColor colorWithRed:0/255.0 green:172/255.0 blue:101/255.0 alpha:1.0],
                  //Orange
                  [UIColor colorWithRed:233/255.0 green:102/255.0 blue:44/255.0 alpha:1.0],
                  //Blue
                  [UIColor colorWithRed:22/255.0 green:194/255.0 blue:239/255.0 alpha:1.0],
                  nil];

    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [categories addSubview:refreshControl];
    
    //[[btnSuggestion1 titleLabel] setNumberOfLines:0];
    //[[btnSuggestion2 titleLabel] setNumberOfLines:0];
    [btnSuggestion2 setFrame:CGRectMake([btnSuggestion2 frame].origin.x, [btnSuggestion2 frame].origin.y, [btnSuggestion1 frame].size.width, [btnSuggestion1 frame].size.height)];
    CGRect frmLabel = CGRectMake(0, 0, [btnSuggestion1 frame].size.width, [btnSuggestion1 frame].size.height);
    lblSuggestion1 = [[UILabel alloc] initWithFrame:frmLabel];
    lblSuggestion2 = [[UILabel alloc] initWithFrame:frmLabel];
    [lblSuggestion1 setFont:[[btnSuggestion1 titleLabel] font]];
    [lblSuggestion2 setFont:[[btnSuggestion2 titleLabel] font]];
    [lblSuggestion1 setTextAlignment:NSTextAlignmentCenter];
    [lblSuggestion2 setTextAlignment:NSTextAlignmentCenter];
    [lblSuggestion1 setTextColor:[UIColor whiteColor]];
    [lblSuggestion2 setTextColor:[UIColor whiteColor]];
    [btnSuggestion1 addSubview:lblSuggestion1];
    [btnSuggestion2 addSubview:lblSuggestion2];
    
    UIImage* settings = [UIImage imageNamed:@"gear.png"];
    UIImage *scaledSettings =
    [UIImage imageWithCGImage:[settings CGImage]
                        scale:73.0/30
                  orientation:(settings.imageOrientation)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:scaledSettings
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(settings:)];
    [[self navigationItem] setRightBarButtonItem: rightButton];
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    
    if (ShowIntro) {
        [self showWalkthrough];
    
        ShowIntro = NO;
        [Settings SaveSetting:SettingShowIntro withValue:@"0"];
    }
    
    [Data addListener:self];

    [categories setDelegate:self];
    [categories setDataSource:self];
    
    [categories reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    reminderButtonState = SHOW_TEXT;
    
    if (timerReminder == nil) {
        timerReminder = [NSTimer scheduledTimerWithTimeInterval:2.0
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
    NSInteger c = ((ChosenCategories == nil) ? [[Data getCategories] count] : [ChosenCategories count]);
    if (c > [ChosenCategories count])
        NSLog(@"why am i here?");
    
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
    Message* msg;
    NSArray* cs = [Data getCategories];
    category = [cs objectAtIndex:icategory];
    msg = [[Data getMessagesForCategory:category] objectAtIndex:0];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell showForWidth:[[self view] frame].size.width
             withColor:[colors objectAtIndex:[indexPath row]%[colors count]]
                 title:category
              newCount:[Data getNewMessageCountForCategory:category]
               message:msg];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    long icategory = [self chosenCategory:[indexPath row]];

    CurrentColorIndex = icategory % [colors count];
    CurrentCategory = [[Data getCategories] objectAtIndex:icategory];
    CurrentMessage = nil;
    
    [self performSegueWithIdentifier:@"SelectMessage" sender:self];
}

-(long) chosenCategory:(long)selectedCategory {
    long icategory = selectedCategory;
    if (ChosenCategories != nil) {
        NSArray* cats = [Data getCategories];
        icategory = 0;
        for (int ichosen = 0; icategory<[cats count] && ichosen <= [cats count]; icategory++) {
            NSString* tmp = [cats objectAtIndex:icategory];
            if ([ChosenCategories containsObject:tmp]) {
                if (ichosen == selectedCategory)
                    break;
                else
                    ichosen++;
            }
        }
    }

    return icategory;
}

-(IBAction)sendRandomMessage:(id)sender {
    CurrentMessage = randomMessage;
    CurrentCategory = [randomMessage category];
    //[self performSegueWithIdentifier:@"ChooseContactForMessage" sender:self];
    //[[self navigationController] performSegueWithIdentifier:@"ChooseContactForMessage" sender:self];
}

-(IBAction)settings:(id)sender {
    [self performSegueWithIdentifier:@"Settings" sender:self];
}

-(void)setReminder:(NSTimer*)timer {
    if (reminderButtonState == TIMER_PAUSED)
        return;
    
    if (reminderButtonState == SHOW_CONTACT && [Data getContacts] == nil)
        reminderButtonState = SHOW_TEXT;
    unsigned long colorcount = [colors count];
    unsigned int icolor = rand() % colorcount;
    
    switch (reminderButtonState) {
            /*
        case HIDE_TEXT:
        case HIDE_CONTACT:
            [self fadeout];
            break;
             */
        case SHOW_TEXT:
            [btnSuggestion1 setBackgroundColor:[colors objectAtIndex:icolor]];
            randomMessage = [Data chooseRandomMessage];
            while ([randomMessage mediaUrl] != nil && [randomMessage img] == nil) {
                ImageDownloader* load =
                    [[ImageDownloader alloc] initWithUrl:[randomMessage mediaUrl]
                                              forMessage:randomMessage];
                [load load];
                randomMessage = [Data chooseRandomMessage];
            }
            if (([randomMessage text] == nil) || [[randomMessage text] length] == 0) {
                //[btnSuggestion1 setTitle:@"" forState:UIControlStateNormal];
                [lblSuggestion1 setText:@""];
                [lblSuggestion1 setHidden:YES];
            }
            else {
                //[btnSuggestion1 setTitle:[randomMessage text] forState:UIControlStateNormal];
                [lblSuggestion1 setText:[randomMessage text]];
                [lblSuggestion1 setHidden:NO];
            }
            if ([randomMessage mediaUrl] == nil) {
                [btnSuggestion1 setBackgroundImage:nil forState:UIControlStateNormal];
                [lblSuggestion1 setFrame:CGRectMake(4, 4, [btnSuggestion1 frame].size.width-8, [btnSuggestion1 frame].size.height-8)];
                //[btnSuggestion1 setTitle:[randomMessage text] forState:UIControlStateNormal];
                [lblSuggestion1 setBackgroundColor:[UIColor clearColor]];
                [lblSuggestion1 setNumberOfLines:0];
                [lblSuggestion1 setAlpha:1];
            }
            else {
                CGRect frm = CGRectMake(0, [btnSuggestion1 frame].size.height-22, [btnSuggestion1 frame].size.width, 22);
                [lblSuggestion1 setFrame:frm];
                [btnSuggestion1 setBackgroundImage:[UIImage imageWithData:[randomMessage img]]
                                         forState:UIControlStateNormal];
                [lblSuggestion1 setNumberOfLines:1];
                [lblSuggestion1 setBackgroundColor:[UIColor grayColor]];
                [lblSuggestion1 setAlpha:0.70];
            }
            
            [self fadein];
            break;
        case SHOW_CONTACT:
            [btnSuggestion2 setBackgroundColor:[colors objectAtIndex:icolor]];
            randomMessage = [Data chooseRandomMessage];
            while ([randomMessage mediaUrl] != nil && [randomMessage img] == nil) {
                ImageDownloader* load =
                [[ImageDownloader alloc] initWithUrl:[randomMessage mediaUrl]
                                          forMessage:randomMessage];
                [load load];
                randomMessage = [Data chooseRandomMessage];
            }
            if (([randomMessage text] == nil) || [[randomMessage text] length] == 0) {
                //[btnSuggestion2 setTitle:@"" forState:UIControlStateNormal];
                [lblSuggestion2 setText:@""];
                [lblSuggestion2 setHidden:YES];
            }
            else {
                //[btnSuggestion2 setTitle:[randomMessage text] forState:UIControlStateNormal];
                [lblSuggestion2 setText:[randomMessage text]];
                [lblSuggestion2 setHidden:NO];
            }
            if ([randomMessage img] == nil) {
                [btnSuggestion2 setBackgroundImage:nil forState:UIControlStateNormal];
                [lblSuggestion2 setFrame:CGRectMake(4, 4, [btnSuggestion2 frame].size.width-8, [btnSuggestion2 frame].size.height-8)];
                //[btnSuggestion2 setTitle:[randomMessage text] forState:UIControlStateNormal];
                [lblSuggestion2 setBackgroundColor:[UIColor clearColor]];
                [lblSuggestion2 setNumberOfLines:0];
                [lblSuggestion2 setAlpha:1];
            }
            else {
                CGRect frm = CGRectMake(0, [btnSuggestion2 frame].size.height-22, [btnSuggestion2 frame].size.width, 22);
                [lblSuggestion2 setFrame:frm];
                [btnSuggestion2 setBackgroundImage:[UIImage imageWithData:[randomMessage img]]
                                          forState:UIControlStateNormal];
                [lblSuggestion2 setBackgroundColor:[UIColor grayColor]];
                [lblSuggestion2 setNumberOfLines:1];
                [lblSuggestion2 setAlpha:0.70];
            }
            
            
            [self fadeout];
            
            break;
    }
    reminderButtonState = (reminderButtonState + 1) % BUTTON_STATES;
}

-(void)fadein {
    /*
    [btnSuggestion setAlpha:0.0f];
    [UIView animateWithDuration:1.0f animations:^{ [btnSuggestion setAlpha:1.0f]; }
                     completion:^(BOOL finished) {}];
     */
    CGRect frmStart1 = [btnSuggestion1 frame];
    frmStart1.origin.x = [[self view] frame].size.width + 8;
    [btnSuggestion1 setFrame:frmStart1];
    [btnSuggestion1 setHidden:NO];
    CGRect frmStart2 = [btnSuggestion2 frame];
    CGRect frmDest1 = frmStart1;
    frmDest1.origin.x = 0;
    CGRect frmDest2 = frmStart2;
    frmDest2.origin.x = -[[self view] frame].size.width - 8;
    [UIView animateWithDuration:1.0f animations:^{
        [btnSuggestion1 setFrame:frmDest1];
        [btnSuggestion2 setFrame:frmDest2];
    }];
}

-(void)fadeout {
    /*
    [btnSuggestion setAlpha:1.0f];
    [UIView animateWithDuration:1.0f animations:^{ [btnSuggestion setAlpha:0.0f]; }
                     completion:^(BOOL finished) {}];
     */
    CGRect frmStart2 = [btnSuggestion2 frame];
    frmStart2.origin.x = [[self view] frame].size.width + 8;
    [btnSuggestion2 setFrame:frmStart2];
    [btnSuggestion2 setHidden:NO];
    CGRect frmStart1 = [btnSuggestion1 frame];
    CGRect frmDest2 = frmStart1;
    frmDest2.origin.x = 0;
    CGRect frmDest1 = frmStart1;
    frmDest1.origin.x = -[[self view] frame].size.width - 8;
    [UIView animateWithDuration:1.0f animations:^{
        [btnSuggestion1 setFrame:frmDest1];
        [btnSuggestion2 setFrame:frmDest2];
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

-(IBAction)closeWalkthrough:(id)sender {
    [walkthroughView removeFromSuperview];
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = [scroller frame].size.width;
    int page = floor(([scroller contentOffset].x - pageWidth / 2) / pageWidth) + 1;
    
    [pages setCurrentPage: page];
}

- (IBAction)pageTurn:(id)sender {
    long page = [pages currentPage];
    CGRect frm = [scroller frame];
    CGPoint p = [scroller contentOffset];
    [scroller setContentOffset:CGPointMake(page * frm.size.width, p.y)];
}

@end
