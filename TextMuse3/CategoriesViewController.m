//
//  ViewController.m
//  TextMuse2
//
//  Created by Peter Tucker on 4/18/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "CategoriesViewController.h"
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
    
    [[btnSuggestion1 titleLabel] setNumberOfLines:0];
    [[btnSuggestion2 titleLabel] setNumberOfLines:0];
    
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
    
    [Data addListener:self];

    if (ShowIntro) {
        [self performSegueWithIdentifier:@"Walkthrough" sender:self];
        
        ShowIntro = NO;
        [Settings SaveSetting:SettingShowIntro withValue:@"0"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [categories setDelegate:self];
    [categories setDataSource:self];
    
    [categories reloadData];

    reminderButtonState = SHOW_TEXT;
    if (timerReminder == nil) {
        timerReminder = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                         target:self
                                                       selector:@selector(setReminder:)
                                                       userInfo:nil
                                                        repeats:YES];
    }
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
    return ((ChosenCategories == nil) ? [[Data getCategories] count] : [ChosenCategories count]);
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
        int ichosen = 0;
        for (; icategory<[cats count] && ichosen <= selectedCategory; icategory++) {
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
    
    reminderButtonState = (reminderButtonState + 1) % BUTTON_STATES;
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
            if (([randomMessage text] == nil) || [[randomMessage text] length] == 0)
                [btnSuggestion1 setTitle:@"" forState:UIControlStateNormal];
            else
                [btnSuggestion1 setTitle:[randomMessage text] forState:UIControlStateNormal];
            if ([randomMessage mediaUrl] == nil) {
                [btnSuggestion1 setBackgroundImage:nil forState:UIControlStateNormal];
                [btnSuggestion1 setTitle:[randomMessage text] forState:UIControlStateNormal];
            }
            else {
                [btnSuggestion1 setBackgroundImage:[UIImage imageWithData:[randomMessage img]]
                                         forState:UIControlStateNormal];
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
            if (([randomMessage text] == nil) || [[randomMessage text] length] == 0)
                [btnSuggestion2 setTitle:@"" forState:UIControlStateNormal];
            else
                [btnSuggestion2 setTitle:[randomMessage text] forState:UIControlStateNormal];
            if ([randomMessage img] == nil) {
                [btnSuggestion2 setBackgroundImage:nil forState:UIControlStateNormal];
                [btnSuggestion2 setTitle:[randomMessage text] forState:UIControlStateNormal];
            }
            else {
                [btnSuggestion2 setBackgroundImage:[UIImage imageWithData:[randomMessage img]]
                                          forState:UIControlStateNormal];
            }
            
            [self fadeout];
            
            break;
    }
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

@end
