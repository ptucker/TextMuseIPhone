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
#import "SqlData.h"
#import "SuccessParser.h"

NSString* urlHighlightNote = @"http://www.textmuse.com/admin/notelike.php";
NSString* urlFlagNote = @"http://www.textmuse.com/admin/flagmessage.php";
NSString* urlRemitBadge = @"http://www.textmuse.com/admin/remitbadge.php";
NSString* urlViewCategory = @"http://www.textmuse.com/admin/viewcategory.php";
NSString* urlRemitDeal = @"http://www.textmuse.com/admin/remitdeal.php";

@interface MessagesViewController ()

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[self navigationItem] backBarButtonItem] setTitle:@"Back"];
    NSDictionary* txtAttrs =[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIFont fontWithName:@"Lato-Medium" size:18.0], NSFontAttributeName, nil];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:txtAttrs forState:UIControlStateNormal];
    
    MessageCategory* mc = [Data getCategory:CurrentCategory];
    if (![CurrentCategory isEqualToString:@"PinnedMessages"])
    {
        if ([CurrentCategory isEqualToString:@"Badges"])
            [self setRightButtonRemit];
        else {
            [self setRightButtonFlag];

            if ([mc catid] != 0) {
                NSURL* url = [NSURL URLWithString:urlViewCategory];
                NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url
                                                                   cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                               timeoutInterval:30];
                inetdata = [[NSMutableData alloc] init];
                [req setHTTPMethod:@"POST"];
                [req setHTTPBody:[[NSString stringWithFormat:@"app=%@&cat=%d", AppID, [mc catid]]
                                  dataUsingEncoding:NSUTF8StringEncoding]];
                
                NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                                        delegate:self
                                                                startImmediately:YES];
            }
        }
    }
    else
        [[self navigationItem] setRightBarButtonItem: nil];

    UIColor* currColor = [colors objectAtIndex:CurrentColorIndex];
    [header setBackgroundColor:currColor];
    [headerLabel setBackgroundColor:currColor];
    [headerLabel setTextColor:[colorsText objectAtIndex:CurrentColorIndex]];
    [headerLabel setText:CurrentCategory];

    //[selectButton setBackgroundColor:currColor];
    //[selectButton setTitleColor:[colorsText objectAtIndex:CurrentColorIndex] forState:UIControlStateNormal];
    CGRect frmSelect = CGRectMake([[self view] frame].size.width/2 - 72, 24, 144, 36);
    selectButton = [[UICaptionButton alloc] initWithFrame:frmSelect
                                                withImage:[UIImage imageNamed:@"TextMuseButton"]
                                                  andRightText:@"text it"];
    [selectButton addTarget:self action:@selector(chooseMessage:) forControlEvents:UIControlEventTouchUpInside];
    [lowerView addSubview:selectButton];
    
    [scrollview setDelegate:self];

    [self showMessages];
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
    NSArray* quotes = [CurrentCategory isEqualToString:@"PinnedMessages"] ? [Data getPinnedMessages] :
                        [Data getMessagesForCategory:CurrentCategory];
    if ([quotes count] == 0) return;
    
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = [scrollview frame].size.width;
    int page = floor(([scrollview contentOffset].x - pageWidth / 2) / pageWidth) + 1;
    
    Message* msg = [quotes objectAtIndex:page];
    if ([msg liked])
        [highlightButton setImage:[UIImage imageNamed:@"yellowHighlighter.png"]
                         forState:UIControlStateNormal];
    else
        [highlightButton setImage:[UIImage imageNamed:@"greyHighlighter.png"]
                         forState:UIControlStateNormal];
    
    [pages setCurrentPage: (page / pageDivisor)];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    //Append the newly arrived data to whatever we’ve seen so far
    [inetdata appendData:data];
}

-(void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error {
    //NSLog([error localizedDescription]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)_connection{
    SuccessParser* sp = [[SuccessParser alloc] initWithXml:inetdata];
    
    [CurrentUser setExplorerPoints:[sp ExplorerPoints]];
    [CurrentUser setSharerPoints:[sp SharerPoints]];
    [CurrentUser setMusePoints:[sp MusePoints]];
    //NSString* data = [[NSString alloc] initWithData:inetdata encoding:NSUTF8StringEncoding];
    //NSLog(data);
}

-(void)setRightButtonFlag {
    UIImage* flagit = [UIImage imageNamed:@"flag-variant.png"];
    UIImage *scaledFlag = [UIImage imageWithCGImage:[flagit CGImage]
                                              scale:48.0/30
                                        orientation:(flagit.imageOrientation)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:scaledFlag
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(flagit:)];
    [[self navigationItem] setRightBarButtonItem: rightButton];
}

-(void)setRightButtonRemit {
    UIImage* flagit = [UIImage imageNamed:@"currency-usd.png"];
    UIImage *scaledFlag = [UIImage imageWithCGImage:[flagit CGImage]
                                              scale:48.0/30
                                        orientation:(flagit.imageOrientation)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:scaledFlag
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(remitit:)];
    [[self navigationItem] setRightBarButtonItem: rightButton];
}

-(void)showMessages {
    for (UIView* v in [scrollview subviews])
        [v removeFromSuperview];
    
    CGRect frame = [scrollview frame];
    frameStart = CGRectMake(0, 0, frame.size.width, frame.size.height);
    NSArray* msgs = [CurrentCategory isEqualToString:@"PinnedMessages"] ? [Data getPinnedMessages] :
                                                                    [Data getMessagesForCategory:CurrentCategory];
    for (int i=0; i<[msgs count]; i++) {
        Message* msg = [msgs objectAtIndex:i];
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
    
    Message* msg = [msgs objectAtIndex:0];
    if ([msg liked])
        [highlightButton setImage:[UIImage imageNamed:@"yellowHighlighter.png"]
                         forState:UIControlStateNormal];
    else
        [highlightButton setImage:[UIImage imageNamed:@"greyHighlighter.png"]
                         forState:UIControlStateNormal];
    
    unsigned long cnt = [msgs count];
    [scrollview setContentSize:CGSizeMake(frame.size.width * cnt, frame.size.height)];
    
    //Only allow up to 15 dots
    pageDivisor = (cnt/15) + 1;
    [pages setNumberOfPages:(cnt/pageDivisor)];
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

-(IBAction)flagit:(id)sender {
    CGFloat pageWidth = [scrollview frame].size.width;
    int p = floor(([scrollview contentOffset].x - pageWidth / 2) / pageWidth) + 1;
    NSArray* msgs = [CurrentCategory isEqualToString:@"PinnedMessages"] ? [Data getPinnedMessages] :
    [Data getMessagesForCategory:CurrentCategory];
    Message*msg = [msgs objectAtIndex:p];
    
    NSString* msgText = [[msg text] length] > 0 ? [msg text] : @"this message";
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Flag as inappropriate?"
                                                    message:[NSString stringWithFormat:@"Are you sure you want to flag %@ as inappropriate?", msgText]
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Yes Button", nil)
                                          otherButtonTitles:NSLocalizedString(@"No Button", nil), nil];
    [alert setTag:100];
    [alert show];
}

-(IBAction)remitit:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Remit badge?"
                                                    message:@"Are you sure you want to remit this badge?"
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Yes Button", nil)
                                          otherButtonTitles:NSLocalizedString(@"No Button", nil), nil];
    [alert setTag:101];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0 && ([alertView tag] == 100 || [alertView tag] == 101)) {
        CGFloat pageWidth = [scrollview frame].size.width;
        int p = floor(([scrollview contentOffset].x - pageWidth / 2) / pageWidth) + 1;
        NSArray* msgs = [CurrentCategory isEqualToString:@"PinnedMessages"] ? [Data getPinnedMessages] :
        [Data getMessagesForCategory:CurrentCategory];
        Message*msg = [msgs objectAtIndex:p];
        
        [SqlDb flagMessage:msg];
        [Data reloadData];
        
        NSMutableURLRequest* req = nil;
        if ([alertView tag] == 100) {
            req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlFlagNote]
                                          cachePolicy:NSURLRequestReloadIgnoringCacheData
                                      timeoutInterval:30];
            [req setHTTPBody:[[NSString stringWithFormat:@"id=%ld", (long)[msg msgId]]
                              dataUsingEncoding:NSUTF8StringEncoding]];
            
        }
        else if ([alertView tag] == 101) {
            req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlRemitBadge]
                                          cachePolicy:NSURLRequestReloadIgnoringCacheData
                                      timeoutInterval:30];
            [req setHTTPBody:[[NSString stringWithFormat:@"app=%@&game=%ld", AppID, -1*(long)[msg msgId]]
                              dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [req setHTTPMethod:@"POST"];
        NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                                delegate:nil
                                                        startImmediately:YES];
        
        if ([msgs count] == 1) {
            //if we deleted the only one, then get out of this view
            [[self navigationController] popViewControllerAnimated:YES];
        }
        else {
            [self showMessages];
            
            //If we deleted the last one, scroll to the new last one
            if (p == [msgs count]-1) {
                CGRect frame = [scrollview frame];
                CGRect frameScroll = CGRectMake([scrollview contentSize].width - frame.size.width, 0,
                                                frame.size.width, frame.size.height);
                [scrollview scrollRectToVisible:frameScroll animated:YES];
            }
        }
    }
}

-(IBAction)chooseMessage:(id)sender {
    //long p = [pages currentPage];
    CGFloat pageWidth = [scrollview frame].size.width;
    int p = floor(([scrollview contentOffset].x - pageWidth / 2) / pageWidth) + 1;
    NSArray* msgs = [CurrentCategory isEqualToString:@"PinnedMessages"] ? [Data getPinnedMessages] :
                                        [Data getMessagesForCategory:CurrentCategory];
    CurrentMessage = [msgs objectAtIndex:p];

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
    NSArray* quotes = [CurrentCategory isEqualToString:@"PinnedMessages"] ? [Data getPinnedMessages] :
                                    [Data getMessagesForCategory:CurrentCategory];
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
