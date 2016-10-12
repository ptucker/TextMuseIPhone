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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self feedback] setText:@"Add your message..."];
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Register for the events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidShow:)
                                                 name: UIKeyboardDidShowNotification
                                               object:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) keyboardDidShow: (NSNotification *)notif {
    // Get the size of the keyboard.
    NSDictionary* info = [notif userInfo];
    CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;

    CGRect frmName = [[self name] frame];
    CGRect frmEmail = [[self email] frame];
    CGRect frmFeedback = [[self feedback] frame];
    
    frmName.origin.y = frmEmail.origin.y =
            [[self view] frame].size.height - kbHeight - frmName.size.height - 4;
    [[self name] setFrame:frmName];
    [[self email] setFrame:frmEmail];
    
    frmFeedback.size.height = frmName.origin.y - 4 - frmFeedback.origin.y;
    [[self feedback] setFrame:frmFeedback];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Add your message..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Add your message...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

-(IBAction)sendFeedback:(id)sender {
    if ([[[self feedback] text] length] > 0 &&
            ![[[self feedback] text] isEqualToString: @"Add your message..."]) {
        NSURL* url = [NSURL URLWithString:urlFeedback];
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:30];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[[NSString stringWithFormat:@"name=%@&email=%@&feedback=%@",
                           [[self name] text], [[self email] text], [[self feedback] text]]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                                delegate:self
                                                        startImmediately:YES];
        
        [[self navigationController] popViewControllerAnimated:YES];
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
