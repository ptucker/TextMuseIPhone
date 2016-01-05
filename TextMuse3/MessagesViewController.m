//
//  MessagesViewController.m
//  TextMuse2
//
//  Created by Peter Tucker on 4/19/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "MessagesViewController.h"
#import "RndMessagesViewController.h"
#import "Message.h"
#import "MessageView.h"
#import "Settings.h"
#import "GlobalState.h"
#import "DataAccess.h"

NSString* urlHighlightNote = @"http://www.textmuse.com/admin/notelike.php";

@interface MessagesViewController ()

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[self navigationItem] backBarButtonItem] setTitle:@"Back"];
    NSDictionary* txtAttrs =[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIFont fontWithName:@"Lato-Medium" size:18.0], NSFontAttributeName, nil];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:txtAttrs forState:UIControlStateNormal];
    
    UIColor* currColor = [colors objectAtIndex:CurrentColorIndex];
    [header setBackgroundColor:currColor];
    [headerLabel setBackgroundColor:currColor];
    [headerLabel setTextColor:[colorsText objectAtIndex:CurrentColorIndex]];
    [headerLabel setText:CurrentCategory];

    [selectButton setBackgroundColor:currColor];
    [selectButton setTitleColor:[colorsText objectAtIndex:CurrentColorIndex] forState:UIControlStateNormal];
    
    [scrollview setDelegate:self];

    CGRect frame = [scrollview frame];
    frameStart = CGRectMake(0, 0, frame.size.width, frame.size.height);
    for (int i=0; i<[[Data getMessagesForCategory:CurrentCategory] count]; i++) {
        Message* msg = [[Data getMessagesForCategory:CurrentCategory] objectAtIndex:i];
        MessageView* mv = [[MessageView alloc] initWithFrame:frame];
    
        [mv setupViewForMessage:msg
                        inFrame:frame
                      withColor:[colors objectAtIndex:CurrentColorIndex]
                          index:CurrentColorIndex];
    
        [scrollview addSubview:mv];
        if (CurrentMessage != nil && [CurrentMessage msgId] == [msg msgId])
            frameStart.origin.x = frame.origin.x;
        frame.origin.x += frame.size.width;
    }
    
    Message* msg = [[Data getMessagesForCategory:CurrentCategory] objectAtIndex:0];
    if ([msg liked])
        [highlightButton setImage:[UIImage imageNamed:@"yellowHighlighter.png"]
                         forState:UIControlStateNormal];
    else
        [highlightButton setImage:[UIImage imageNamed:@"greyHighlighter.png"]
                         forState:UIControlStateNormal];

    unsigned long cnt = [[Data getMessagesForCategory:CurrentCategory] count];
    [scrollview setContentSize:CGSizeMake(frame.size.width * cnt, frame.size.height)];

    //Only allow up to 15 dots
    pageDivisor = (cnt/15) + 1;
    [pages setNumberOfPages:(cnt/pageDivisor)];
}

-(void)viewDidAppear:(BOOL)animated {
    if (frameStart.origin.x >= frameStart.size.width)
        [scrollview scrollRectToVisible:frameStart animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    NSArray* quotes = [Data getMessagesForCategory:CurrentCategory];
    if ([quotes count] == 0) return;
    
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = [scrollview frame].size.width;
    int page = floor(([scrollview contentOffset].x - pageWidth / 2) / pageWidth) + 1;
    
    /*
    long p = [pages currentPage];
    Message* m = [quotes objectAtIndex:p];
    if (page != [pages currentPage]) {
        [m setNewMsg:NO];
        if ([starImages count] > 0)
            [[starImages objectAtIndex:p] setHidden:YES];
    }
     */
    
    Message* msg = [quotes objectAtIndex:page];
    if ([msg liked])
        [highlightButton setImage:[UIImage imageNamed:@"yellowHighlighter.png"]
                         forState:UIControlStateNormal];
    else
        [highlightButton setImage:[UIImage imageNamed:@"greyHighlighter.png"]
                         forState:UIControlStateNormal];
    
    [pages setCurrentPage: (page / pageDivisor)];
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = [scrollview frame].size.width * [pages currentPage];
    frame.origin.y = 0;
    frame.size = [scrollview frame].size;
    [scrollview scrollRectToVisible:frame animated:YES];
}

-(IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)chooseMessage:(id)sender {
    //long p = [pages currentPage];
    CGFloat pageWidth = [scrollview frame].size.width;
    int p = floor(([scrollview contentOffset].x - pageWidth / 2) / pageWidth) + 1;
    CurrentMessage = [[Data getMessagesForCategory:CurrentCategory] objectAtIndex:p];

    if ([[Data getContacts] count] == 0) {
        if (sendMessage == nil)
            sendMessage = [[SendMessage alloc] init];
        [sendMessage sendMessageTo:nil from:self];
    }
    else
        [self performSegueWithIdentifier:@"ChooseContact" sender:self];
}

-(IBAction)highlightMessage:(id)sender {
    UIButton* btn = (UIButton*) sender;
        
    CGFloat pageWidth = [scrollview frame].size.width;
    int page = floor(([scrollview contentOffset].x - pageWidth / 2) / pageWidth) + 1;
    NSArray* quotes = [Data getMessagesForCategory:CurrentCategory];
    Message*m = [quotes objectAtIndex:page];
    [m setLiked:![m liked]];
        
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlHighlightNote]
                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                   timeoutInterval:30];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[[NSString stringWithFormat:@"id=%ld&app=%@&h=%d",
                       (long)[m msgId], AppID, ([m liked] ? 1 : 0)]
                      dataUsingEncoding:NSUTF8StringEncoding]];
        
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:nil
                                                    startImmediately:YES];
        
    NSString* highlighter = [m liked] ? @"yellowHighlighter.png" : @"greyHighlighter.png";
    [btn setImage:[UIImage imageNamed: highlighter] forState:UIControlStateNormal];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
