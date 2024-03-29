//
//  AddEventViewController.m
//  TextMuse
//
//  Created by Peter Tucker on 2/26/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import "AddEventViewController.h"
#import "Settings.h"
#import "GlobalState.h"
#import "SuccessParser.h"
#import "EmailValidator.h"

@interface AddEventViewController ()

@end

NSString* placeholderText = @"Description *";
NSString* urlAddEvent = @"https://www.textmuse.com/admin/addevent.php";
NSString* urlAddPrayer = @"https://www.textmuse.com/admin/addprayer.php";
NSString* eventLabel = @"Add an event so others around you can know what's going on.";
NSString* eventSubmit = @"Submit event";
NSString* prayerLabel = @"Submit a prayer request so others can pray for you.";
NSString* prayerSubmit = @"Submit prayer";

@implementation AddEventViewController
@synthesize singleTapRecognizer = _singleTapRecognizer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [txtLocation setHidden:(AddContent == AddPrayer)];

    [[self view] addGestureRecognizer:[self singleTapRecognizer]];
    [tvDesc setText:placeholderText];
    [tvDesc setTextColor:[UIColor darkGrayColor]];
    [tvDesc setDelegate:self];
    
    [lbl setText:(AddContent == AddPrayer) ? prayerLabel : eventLabel];
    [btnSubmit setTitle:(AddContent == AddPrayer) ? prayerSubmit : eventSubmit forState:UIControlStateNormal];
    
    if ([[CurrentUser UserEmail] length] > 0)
        [txtEmail setText:[CurrentUser UserEmail]];
    
    if (Skin != nil)
        [btnSubmit setBackgroundColor:[Skin getDarkestColor]];
    else
        [btnSubmit setBackgroundColor:[UIColor darkGrayColor]];
}

-(void)viewWillAppear:(BOOL)animated {
    CGSize sz = [[self view] frame].size;
    sz.height = sz.height + 200;
    [scroller setContentSize:sz];
    [scroller setFrame:[[self view] frame]];
    
    NSArray* views = [NSArray arrayWithObjects:lbl, tvDesc, txtEmail, txtLocation, txtDate, btnSubmit, nil];
    for (UIView* v in views) {
        CGRect frm = [v frame];
        frm.size.width = sz.width - 40;
        [v setFrame:frm];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSString* tv = [textView text];

    if ([tv isEqualToString:placeholderText]) {
        [textView setText:@""];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if ([[textView text] length] == 0)
        [textView setText:placeholderText];
}

- (void) textViewDidChange:(UITextView *)textView{

    if ([[textView text] length] == 0){
        [textView setTextColor: [UIColor darkGrayColor]];
        [textView setText: placeholderText];
        [textView setSelectedRange:NSMakeRange(0, 0)];
        
    } else if ([textView textColor] == [UIColor darkGrayColor] &&
               ![textView.text isEqualToString:placeholderText]) {
        [textView setText: [[textView text] substringToIndex:1]];
        [textView setTextColor: [UIColor blackColor]];
    }
}

- (UITapGestureRecognizer *)singleTapRecognizer
{
    if (nil == _singleTapRecognizer) {
        _singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapToDismissKeyboard:)];
        _singleTapRecognizer.cancelsTouchesInView = NO; // absolutely required, otherwise "tap" eats events.
    }
    return _singleTapRecognizer;
}

// Something inside this VC's view was tapped (except the navbar/toolbar)
- (void)singleTapToDismissKeyboard:(UITapGestureRecognizer *)sender
{
    [self hideKeyboard:sender];
}

// When the "Return" key is pressed on the on-screen keyboard, hide the keyboard.
// for protocol UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [self hideKeyboard:textField];
    return YES;
}

- (IBAction)hideKeyboard:(id)sender
{
    // Just call resignFirstResponder on all UITextFields and UITextViews in this VC
    // Why? Because it works and checking which one was last active gets messy.
    [tvDesc resignFirstResponder];
    [txtDate resignFirstResponder];
    [txtLocation resignFirstResponder];
    [txtEmail resignFirstResponder];
}

-(IBAction)submitEvent:(id)sender {
    
    BOOL legal = [[tvDesc text] length] > 0 && [[txtDate text] length] > 0 && [[txtEmail text] length] > 0;
    legal &= [EmailValidator IsValidEmail:[txtEmail text] Strict:YES];
    
    if (!legal) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Event"
                                                        message:@"Your event must complete all required fields, and give a valid email address."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        NSURL* url = (AddContent == AddPrayer ? [NSURL URLWithString:urlAddPrayer] : [NSURL URLWithString:urlAddEvent]);
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:30];
        [req setHTTPMethod:@"POST"];
        NSString* desc = [[tvDesc text] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        NSString* date = [[txtDate text] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        NSString* email = [[txtEmail text] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        NSString* loc = [[txtLocation text] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        NSString* urlStr = [NSString stringWithFormat:@"desc=%@&edate=%@&email=%@&spon=%ld&app=%@",
                            desc, date, email, [Skin SkinID], AppID];
        if ([[txtLocation text] length] > 0)
            urlStr = [NSString stringWithFormat:@"%@&loc=%@", urlStr, loc];
        NSData* urlData = [urlStr dataUsingEncoding:NSUTF8StringEncoding];
        [req setHTTPBody:urlData];
        inetdata = [[NSMutableData alloc] init];
        NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                                delegate:self
                                                        startImmediately:YES];
    }
}

-(void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [inetdata appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //NSLog([error localizedDescription]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event Submission Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
}

-(void)connectionDidFinishLoading:(NSURLConnection*) connection {
    NSString* msg = [[NSString alloc] initWithData:inetdata encoding:NSUTF8StringEncoding];
    NSString* title = @"Failed";
    if ([msg containsString:@"<blocked/>"])
        msg = @"Please refrain from foul language in your content";
    else if ([msg containsString:@"<success"]) {
        msg = @"Your content has been uploaded";
        title = @"Complete";
        
        [Data reloadData];

        SuccessParser* sp = [[SuccessParser alloc] initWithXml:inetdata];
        
        [CurrentUser setExplorerPoints:[sp ExplorerPoints]];
        [CurrentUser setSharerPoints:[sp SharerPoints]];
        [CurrentUser setMusePoints:[sp MusePoints]];
    }
    else {
        NSUInteger start = [msg rangeOfString:@"<err>"].location + 5;
        NSUInteger end = [msg rangeOfString:@"</err>"].location;
        if (start < [msg length] && end < [msg length]) {
            msg = [msg substringToIndex:end];
            msg = [msg substringFromIndex:start];
        }
        else
            msg = @"An unknown error occurred";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Content Submission %@",
                                                             title]
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
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
