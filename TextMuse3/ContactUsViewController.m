//
//  ContactUsViewController.m
//  TextMuse3
//
//  Created by Peter Tucker on 5/16/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "ContactUsViewController.h"
#import "Settings.h"

@interface ContactUsViewController ()

@end

@implementation ContactUsViewController

NSString* urlFeedback = @"http://www.textmuse.com/admin/postfeedback.php";
NSString* feedbackPrompt = @"Add your message...";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self feedback] setText:feedbackPrompt];
    [[self feedback] setTextColor:[UIColor lightGrayColor]]; //optional
    [[self feedback] setDelegate:self];
    
    if ([[CurrentUser UserName] length] > 0)
        [[self name] setText:[CurrentUser UserName]];
    if ([[CurrentUser UserEmail] length] > 0)
        [[self email] setText:[CurrentUser UserEmail]];

    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(sendFeedback:)];
    [[self navigationItem] setRightBarButtonItem: rightButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:feedbackPrompt]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = feedbackPrompt;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

-(IBAction)sendFeedback:(id)sender {
    if ([[[self feedback] text] length] > 0 &&
            ![[[self feedback] text] isEqualToString: feedbackPrompt]) {
        NSURL* url = [NSURL URLWithString:urlFeedback];
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:30];
        [req setHTTPMethod:@"POST"];
        NSString* postbody = [NSString stringWithFormat:@"name=%@&email=%@&feedback=%@&version=%ld",
                              [[self name] text], [[self email] text], [[self feedback] text],
                              [Skin SkinID]];
        [req setHTTPBody:[postbody dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                                delegate:self
                                                        startImmediately:YES];
        
        [[self navigationController] popViewControllerAnimated:YES];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Thank you" message:@"Thank you for your feedback" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
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
